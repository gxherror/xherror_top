---
title: "Zigbee设备实现时间获取与计时"
description: 原创
date: 2023-07-16T03:06:03Z
image: zigbee.jpg
math: 
license: 
hidden: false
comments: true
categories:
    - CLOUD
---
# Zigbee设备实现时间获取与计时

## 总体概述

```         
+----------+      +----------+      +-----------+         +-------------+
| 树莓派   |       | 协调器    |      | 终端设备   |        | 传感器      |
+----------+      +----------+      +-----------+         +-------------+
     |                 |                 |					   |
     | 时间戳           |                 |				     |
     +---------------> |                 |					   |
     |                 | 时间戳           | 				     |
     |                 |---------------> |					   |
     |                 |                 |------|			    |
     |                 |                 |      |			    |
     |                 |                 |<-----|			    |
     |                 |                 |时间自增				|
     |                 | 时间戳           |					|
     |                 |<--------------- |					   |
     | 时间戳           |                 |	数据			   |
     |<--------------- |                 |<---------------------|
     |                 |                 |				       |
     
```

## IAR EW for 8051设置

![image-20230511055814122](./../../_resources/image-20230511055814122.png)

![image-20230511055852001](./../../_resources/image-20230511055852001.png)

## 初始化广播

```c
#ifdef ZDO_COORDINATOR
//Coordinator,ZigBee Mini板
//组建网络
  bdb_StartCommissioning( BDB_COMMISSIONING_MODE_NWK_FORMATION |
                          BDB_COMMISSIONING_MODE_FINDING_BINDING );

  //参数255表示一直允许，如果改为0则表示一直不允许；如果改为1~254表示在1~254秒内允许
  NLME_PermitJoiningRequest(255);
#else
//End Device,ZigBee标准板
//设备入网
  bdb_StartCommissioning( BDB_COMMISSIONING_MODE_NWK_STEERING |
                          BDB_COMMISSIONING_MODE_FINDING_BINDING );
#endif
```



## 终端设备时间戳同步

协调器使用属性上报API把时间戳发送给终端设备，终端设备注册ZCL_CMD_REPORT来处理协调器发送的

```c
//ZDO_COORDINATOR
#define ZCLSAMPLESW_UART_BUF_LEN        20
static void zclSampleSw_InitUart(void)
{
  halUARTCfg_t uartConfig;
  /* UART Configuration */
  uartConfig.configured           = TRUE;
  uartConfig.baudRate             = HAL_UART_BR_115200;
  uartConfig.flowControl          = FALSE;
  uartConfig.flowControlThreshold = 0;
  uartConfig.rx.maxBufSize        = ZCLSAMPLESW_UART_BUF_LEN;
  uartConfig.tx.maxBufSize        = ZCLSAMPLESW_UART_BUF_LEN;
  uartConfig.idleTimeout          = 6;
  uartConfig.intEnable            = TRUE;
  uartConfig.callBackFunc         = zclSampleSw_UartCB;
    
  /* Start UART */
  HalUARTOpen(HAL_UART_PORT_0, &uartConfig);
#ifdef ZDO_COORDINATOR
  //coordinator send '1' to raspberry pi to get timestamp
  zclSampleSw_UartBuf[0] = 49;
  HalUARTWrite(HAL_UART_PORT_0 , zclSampleSw_UartBuf , 1);
  zclSampleSw_UartBuf[0] = 0;
#endif
}

/**
 * @fn      zclSampleSw_UartCB
 *
 * @brief   Uart Callback
 */
static void zclSampleSw_UartCB(uint8 port, uint8 event)
{
  uint8 rxLen = Hal_UART_RxBufLen(HAL_UART_PORT_0);
  if(rxLen != 0)
  {
    HalUARTRead(HAL_UART_PORT_0  ,  zclSampleSw_UartBuf , rxLen);
#ifdef ZDO_COORDINATOR
    //coordinator receive timestamp and send ts to to end device 
    zclSampleSw_SendTime(zclSampleSw_UartBuf);
#endif
  }
}


static void zclSampleSw_SendTime(uint8 *zclSampleSw_UartBuf)
{
    afAddrType_t destAddr;//用于保存目标设备的地址信息
    destAddr.endPoint = SAMPLESW_ENDPOINT;//端点号
    destAddr.addrMode = Addr16Bit;//地址模式（类型）为16为的地址，使用P2P的通信方式
    destAddr.addr.shortAddr = zclSampleSw_OnOffTestAddr;//网络地址 
    static uint8 seqNum = 0;  
    zclReportCmd_t *reportCmd;  

    reportCmd = (zclReportCmd_t *)osal_mem_alloc(sizeof(zclReportCmd_t)+sizeof(zclReport_t));//申请内存空间

    if(reportCmd == NULL)//判断内存空间是否申请成功
         return;  
    
    reportCmd->attrList[0].attrData = (uint8 *)osal_mem_alloc(sizeof(uint8)*8);//申请内存空间
    if(reportCmd->attrList[0].attrData == NULL)//判断内存空间是否申请成功
        return;  

    reportCmd->numAttr = 1;//属性数量为1
    reportCmd->attrList[0].attrID = ATTRID_ON_OFF_SWITCH_TYPE;//属性ID
    reportCmd->attrList[0].dataType = ZCL_DATATYPE_UINT64;//数据类型

    strcpy( reportCmd->attrList[0].attrData,zclSampleSw_UartBuf);
    
    //上报数据
    zcl_SendReportCmd(SAMPLESW_ENDPOINT,//源端点号
        &destAddr,//地址信息
        ZCL_CLUSTER_ID_GEN_BASIC,//Cluster ID
        reportCmd,
        ZCL_FRAME_CLIENT_SERVER_DIR,//通信方向为从客户端到服务端
        TRUE,//关闭默认响应（目标设备的响应）
        0 );//数据包标号
    
    //value uint16
    //显示
    set_TimeStamp(reportCmd->attrList[0].attrData);
    show_TimeStamp();
    
    // 释放内存空间！
    osal_mem_free(reportCmd->attrList[0].attrData);  
    osal_mem_free(reportCmd);     
}
```

```c
//ZDO_ENDDEVICE

/*********************************************************************
 * @fn      zclSampleSw_ProcessIncomingMsg
 *
 * @brief   Process ZCL Foundation incoming message
 *
 * @param   pInMsg - pointer to the received message
 *
 * @return  none
 */
static void zclSampleSw_ProcessIncomingMsg( zclIncomingMsg_t *pInMsg )
{
  switch ( pInMsg->zclHdr.commandID )
  {
	...
#ifdef ZCL_REPORT
	...
    case ZCL_CMD_REPORT:
      zclSampleSw_ReceiveTimeCB( pInMsg );
      break;
#endif
    ...
    default:
      break;
  }
  if ( pInMsg->attrCmd )
    osal_mem_free( pInMsg->attrCmd );
}

static void zclSampleSw_ReceiveTimeCB( zclIncomingMsg_t *pInMsg )

   zclReportCmd_t *reportCmd;  
    uint8 i;  
    reportCmd = (zclReportCmd_t *)pInMsg->attrCmd;  
    for ( i = 0; i < reportCmd->numAttr; i++ )//reportCmd->numAttr为属性数量
    {  
      //value uint16
      //显示
      HalLcdWriteString("Received ts", 2);
      set_TimeStamp(reportCmd->attrList[i].attrData);
      show_TimeStamp();
      tsInc = true ;
    }  
}
```



## CC2530 利用Timer进行计时

- Zigbee模块与树莓派初次通讯时，树莓派向Zigbee模块推送当前时间戳，并利用Zigbee模块的CC2530单片机计时器（Timer）中断功能来实现时间戳更新。
- CC2530核心板上带有两颗晶振，计时器3为16位计数器，取高频（32MHZ）晶振的一百二十八分之一作为计数器自加频率，当计数器溢出时发出中断信号，实现每1024微秒发生一次中断。而计时器1可以根据T1CCO寄存器来自定义中断间隔。
- 然而中断处理的耗时会影响时间戳自加的精确性，当中断间隔为毫秒级时，每次中断处理耗时为微秒级，这种误差是难以接受的。

1. Clear interrupt flags. 
2. Set individual interrupt-enable bit in the peripherals SFR register, if any. 
3. Set the corresponding individual interrupt-enable bit in the IEN0, IEN1, or IEN2 register to 1.
4. Enable global interrupt by setting the EA bit in IEN0 to 1. 
5. Begin the interrupt service routine at the corresponding vector address of that interrupt. See Table 2-5 for addresses.

```c
//CC2530
#define INT_PER_MILLI 100;
#define INT_NUM_PER_SECOND = 1000 / INT_PER_MILLI ;

static uint32 counter_interrupt = 0;
static uint32 counter_time = 0;

//timestamp in uint64 format 
//however CC2530 not support uint64 :( (maybe)
static uint32 global_ts_l = 0x0; // milliseconds lower 32bit
static uint32 global_ts_h = 0x0; // milliseconds higher 32bit

/*
 *  Timer3 interrupt service function 
 */
/*
 * Timer3 is 8bit counter, select Timer tick frequency = 32MHz / 128 = 250KHz
 * counter overflow interrupt happen per 1024 microseconds
 * however interrupt costs ~20 microseconds per unit 
 * the deviation is unaccaptable
 */
#pragma vector = T3_VECTOR
__interrupt void Timer3_ISR(void)
{
    //actual time: 669s, measure time: 656s
    uint32 temp = global_ts_l + 1024 ;
    if (global_ts_l > temp ){
      //overflow detected 
      global_ts_h = global_ts_h + 1 ;
    }
    global_ts_l = temp ;
    //~ 1s 
    if (++counter_time == 976 ){
      counter_time = 0;
      show_TimeStamp();
    }
}

void initTimer3(void)
{       
    //HalLcdWriteStringValue("CS: ",CLKCONSTA, 16, 4); ->  default CLKCONCMD = 0x80 
    //meaning that the default timer frequency is 32MHz
    
    T3CTL = 0xE8;  // Tick frequency/128
                   // Overflow interrupt is enabled
                   // Free running, repeatedly count from 0x00 to 0xFF
    
    T3IE = 1;	   // Enable timer3 interrupt
    EA = 1;	       // Enable Interrupts

    T3CTL |= 0x10; // Start timer
}

/*
 *  Timer1 interrupt service function 
 */
/*
 * Timer1 is 16bit counter, select Timer tick frequency = 32MHz / 128 = 250KHz
 * set Timer1 modulo mode, counter overflow interrupt happen
 * according to T1CCO register
 * 
 */
/*
test result :
| int per millisecond | measure time(s) | actual time(s) | int  cost per unit(microsecond) |
| ------------------- | --------------- | -------------- | ------------------------------- |
| 1                   | 1517            | 1552           | 23                              |
| 10                  | 2347            | 2372           | 107                             |
| 10                  | 35342           | 35709          | 104                             |
| 100                 | 30106           | 30108          | 5                               |
| 100                 | 38935           | 38937          | 5                               |
| 250                 | 29537           | 29537          | 0                               |
 */
#pragma vector = T1_VECTOR
__interrupt void Timer1_ISR(void)
{ 
  if (++counter_interrupt == INT_NUM_PER_SECOND ){
    counter_interrupt = 0;
    show_TimeStamp();
    uint32 temp = global_ts_l + 1 ;
    if (global_ts_l > temp ){
    	//overflow detected 
   	 	global_ts_h = global_ts_h + 1 ;
  	}
  global_ts_l = temp ;
  }
}

void initTimer3(void)
{
  CLKCONCMD &= ~0x40;         //选择外部石英晶振
  while(!(SLEEPSTA & 0x40));  //等待晶振稳定    
  CLKCONCMD &= ~0x47;         //TICHSPD二分频，CLKSPD不分频   
  SLEEPCMD |= 0x04;           //关闭RC振荡器   
  
  T1CTL = 0x0E;              //设置定时器T1，128分频，模模式，从0计数到T1CC0     
  
  T1CC0L = 250*INT_PER_MILLI%256;         //装入定时器初值（比较值）
  T1CC0H = 250*INT_PER_MILLI/256;         //interrupt per 0.25s  
  
  T1CCTL0 |= 0x04;            //设置捕获比较通道0为比较模式，用以触发中断
  T1IE = 1;                   //使能Timer1中断
  EA = 1;                     //开启总中断   
}

static void set_TimeStamp(uint8 *var, bool inc){
  memcpy(&global_ts_l,var,sizeof(uint32));
  memcpy(&global_ts_h,var+4,sizeof(uint32));
  if (inc) {
    initTimer3();
  }
}

static void get_TimeStamp(uint8 *var){
  memcpy(var,&global_ts_l,sizeof(uint32));
  memcpy(var+4,&global_ts_h,sizeof(uint32));
}

static void show_TimeStamp(){
  //Lcd show in uint16 format
  HalLcdWriteStringValue("TS0-16: ",global_ts_l, 10, 3);
  HalLcdWriteStringValue("TS16-32: ",(global_ts_l>>16), 10, 4);
}

void zclSampleSw_Init( byte task_id )
{
  set_TimeStamp(timeStampBuf,true);
}
```



## Z-Stack 轮询更新时间戳

- Z-Stack协议本质为OSAL事件驱动，修改Z-Stack协议主循环部分的源码，采用轮询计数器获取两次时间差的方式来更新时间戳，能够实现精度范围在一毫秒级，自增误差可以忽略。然而采用这种方式实现更新时间戳的速度不确定，受事件处理时间的影响。

```c
//ZMain.c

/*********************************************************************
 * @fn      main\
 * @brief   First function called after startup.
 * @return  don't care
 */
int main( void )
{
  // Turn off interrupts
  osal_int_disable( INTS_ALL );

  // Initialize the operating system
  osal_init_system();

  // Allow interrupts
  osal_int_enable( INTS_ALL );
    
  osal_start_system(); // No Return from here

  return 0;  // Shouldn't get here.
} // main()

//OSAL.c
uint32 counter = 0;
//not support uint64 
// milliseconds lower 32bit
uint32 global_ts_l = 0x0;
// milliseconds higher 32bit
uint32 global_ts_h = 0x0;
// CC2530 is little endian 
uint8 tempBuf[8]={0x3,0x0,0x4,0x0,0x1,0x0,0x2,0x0};
bool tsInc = false ; 
extern void HalLcdWriteString ( char *str, uint8 option);
extern void HalLcdWriteStringValue( char *title, uint16 value, uint8 format, uint8 line );

void set_TimeStamp(uint8 *var);
void get_TimeStamp(uint8 *var);
void show_TimeStamp();

void set_TimeStamp(uint8 *var){  
  memcpy(&global_ts_l,var,sizeof(uint32)); 
  memcpy(&global_ts_h,var+4,sizeof(uint32));
}

void get_TimeStamp(uint8 *var){
  memcpy(var,&global_ts_l,sizeof(uint32));
  memcpy(var+4,&global_ts_h,sizeof(uint32));
}

void show_TimeStamp(){
  HalLcdWriteStringValue("TS0-7: ",global_ts_l, 10, 3);
  HalLcdWriteStringValue("TS8-15: ",(global_ts_l>>16), 10, 4);
}



//OSAL.c
/*********************************************************************
 * @fn      osal_init_system
 *
 * @brief
 *
 *   This function initializes the "task" system by creating the
 *   tasks defined in the task table (OSAL_Tasks.h).
 *
 * @param   void
 *
 * @return  SUCCESS
 */
uint8 osal_init_system( void )
{
  // Initialize the timers
  osalTimerInit();
    
  //////////////////////////////////////////////////////////MODIFIED: Timestamp init 
#ifdef ZDO_COORDINATOR
#else
  set_TimeStamp(tempBuf);
#endif
    
#ifdef USE_ICALL
  // Initialize variables used to track timing and provide OSAL timer service
  osal_last_timestamp = (uint_least32_t) ICall_getTicks();
  osal_tickperiod = (uint_least32_t) ICall_getTickPeriod();
  osal_max_msecs = (uint_least32_t) ICall_getMaxMSecs();
  /* Reduce ceiling considering potential latency */
  osal_max_msecs -= 2;
#endif /* USE_ICALL */

  return ( SUCCESS );
}

//OSAL.c
/*********************************************************************
 * @fn      osal_start_system
 *
 * @brief
 *
 *   This function is the main loop function of the task system (if
 *   ZBIT and UBIT are not defined). This Function doesn't return.
 *
 * @param   void
 *
 * @return  none
 */
void osal_start_system( void )
{
#if !defined ( ZBIT ) && !defined ( UBIT )
  for(;;)  // Forever Loop
#endif
  {
    osal_run_system();
  }
}


//OSAL.c
void osal_run_system( void )
{
     osalTimeUpdate();
     /////////////////////////////////////////////////////////MODIFIED: Show ts every ~500ms 
#ifdef ZDO_COORDINATOR
#else
  if (counter >=1000 && tsInc){
     show_TimeStamp();
     counter = 0;
  }
#endif
}


//OSAL_Clock.c
extern uint32 global_ts_l;
extern uint32 global_ts_h;
/*********************************************************************
 * @fn      osalTimeUpdate
 *
 * @brief   Uses the free running rollover count of the MAC backoff timer;
 *          this timer runs freely with a constant 320 usec interval.  The
 *          count of 320-usec ticks is converted to msecs and used to update
 *          the OSAL clock and Timers by invoking osalClockUpdate() and
 *          osalTimerUpdate().  This function is intended to be invoked
 *          from the background, not interrupt level.
 *
 * @param   None.
 *
 * @return  None.
 */
void osalTimeUpdate( void )
{
#ifndef USE_ICALL
  /* Note that when ICall is in use the OSAL tick is not updated
   * in this fashion but rather through real OS timer tick. */
  halIntState_t intState;
  uint32 tmp;
  uint32 ticks320us;
  uint32 elapsedMSec = 0;

  HAL_ENTER_CRITICAL_SECTION(intState);
  // Get the free-running count of 320us timer ticks
  tmp = macMcuPrecisionCount();
  HAL_EXIT_CRITICAL_SECTION(intState);
  
  if ( tmp != previousMacTimerTick )
  {
    // Calculate the elapsed ticks of the free-running timer.
    ticks320us = (tmp - previousMacTimerTick) & 0xffffffffu;

    if (ticks320us >= TIMER_CLOCK_UPDATE )
    {
      // Store the MAC Timer tick count for the next time through this function.
      previousMacTimerTick = tmp;
      
      /*
       * remUsTicks can have a maximum value of 24 (Since remusTicks got by mod 
       * of 25). The value of COUNTER_TICK320US is a multiple of 25 and the 
       * quotient of  CONVERT_320US_TO_MS_ELAPSED_REMAINDER() does not exceed 
       * 0xFFFF or 16 bit.
       */
      while(ticks320us >= COUNTER_TICK320US)
      {
        ticks320us  -= COUNTER_TICK320US;
        elapsedMSec += COUNTER_ELAPSEDMS;
      }
    
      // update converted number with remaining ticks from loop and the
      // accumulated remainder from loop
      tmp = (ticks320us * 8) + remUsTicks;

      // Convert the 320 us ticks into milliseconds and a remainder
      CONVERT_320US_TO_MS_ELAPSED_REMAINDER( tmp, elapsedMSec, remUsTicks );
        
      ///////////////////////////////////////////////////////////MODIFIED: Update ts 
#ifdef ZDO_COORDINATOR
#else
      if (tsInc){
        uint32 temp = global_ts_l + elapsedMSec ;
        if (global_ts_l > temp ){
          //overflow detected 
          global_ts_h = global_ts_h + 1 ;
        }
        global_ts_l = temp ;
      }
#endif
      
      // Update OSAL Clock and Timers
      osalClockUpdate( elapsedMSec );
      osalTimerUpdate( elapsedMSec );
    }
  }
#endif /* USE_ICALL */
}
```

## 时间戳定时更新

- 树莓派定时向Zigbee模块发送当前最新时间戳，Zigbee模块回送自增的时间戳供树莓派计算时间更新误差，树莓派对Zigbee模块回传的每条数据的时间戳进行修正来获取精确的时间戳。

```c
void zclSampleSw_ReceiveTimeCB_EndDevice( zclIncomingMsg_t *pInMsg )
{
   zclReportCmd_t *reportCmd;  
    uint8 i;  

    reportCmd = (zclReportCmd_t *)pInMsg->attrCmd;  

    for ( i = 0; i < reportCmd->numAttr; i++ )//reportCmd->numAttr为属性数量
    {  
      if(reportCmd->attrList[i].attrID == ATTRID_TS_SEND_TYPE){
        
        set_TimeStamp(reportCmd->attrList[i].attrData);
        show_TimeStamp();
        tsInc = true ;
          
        //一小时更新时间
        osal_start_timerEx(
        zclSampleSw_TaskID,//标记本事件属于应用层任务
        SAMPLEAPP_SENDTIME_EVT,//标记本事件的类型
        3600000);//表示3600000ms后才处理这个事件
      }
    }   
}

//每隔3600s利用属性上报将时间戳送回树莓派，再获取最新的时间戳
void zclSampleSw_ReportBackTime()
{
    afAddrType_t destAddr;//用于保存目标设备的地址信息
    destAddr.endPoint = SAMPLESW_ENDPOINT;//端点号
    destAddr.addrMode = Addr16Bit;//地址模式（类型）为16为的地址，使用P2P的通信方式
    destAddr.addr.shortAddr = 0 ;//网络地址 
    static uint8 seqNum = 0;  
    zclReportCmd_t *reportCmd;  

    reportCmd = (zclReportCmd_t *)osal_mem_alloc(sizeof(zclReportCmd_t)+sizeof(zclReport_t));//申请内存空间

    if(reportCmd == NULL)//判断内存空间是否申请成功
         return;  
    
    reportCmd->attrList[0].attrData = (uint8 *)osal_mem_alloc(sizeof(uint8)*8);//申请内存空间
    if(reportCmd->attrList[0].attrData == NULL)//判断内存空间是否申请成功
        return;  

    reportCmd->numAttr = 1;//属性数量为1
    reportCmd->attrList[0].attrID = ATTRID_TS_SEND_BACK_TYPE;//属性ID
    reportCmd->attrList[0].dataType = ZCL_DATATYPE_UINT64;//数据类型

    get_TimeStamp(reportCmd->attrList[0].attrData);

    //上报数据
    zcl_SendReportCmd(SAMPLESW_ENDPOINT,//源端点号
        &destAddr,//地址信息
        ZCL_CLUSTER_ID_GEN_BASIC,//Cluster ID
        reportCmd,
        ZCL_FRAME_CLIENT_SERVER_DIR,//通信方向为从客户端到服务端
        TRUE,//关闭默认响应（目标设备的响应）
        seqNum );//数据包标号，每上报一次数据seqNum的值就会增加1
    
    // 释放内存空间！
    osal_mem_free(reportCmd->attrList[0].attrData);  
    osal_mem_free(reportCmd);      
}
```

```json
{"msg":"zigbee read:  1 ,num:  9"}
{"msg":"----------------------------------------------------------------------"}
{"msg":" old ts: 1686841615101 \n zsb ts: 1686845215102 \n new ts: 1686845216272"}
{"msg":"----------------------------------------------------------------------"}
{"msg":"zigbee read:  1 ,num:  9"}
{"msg":"----------------------------------------------------------------------"}
{"msg":" old ts: 1686845216273 \n zsb ts: 1686848816273 \n new ts: 1686848816500"}
{"msg":"----------------------------------------------------------------------"}
{"msg":"zigbee read:  1 ,num:  9"}
{"msg":"----------------------------------------------------------------------"}
{"msg":" old ts: 1686848816500 \n zsb ts: 1686852416500 \n new ts: 1686852416732"}
{"msg":"----------------------------------------------------------------------"}
{"msg":"zigbee read:  1 ,num:  9"}
{"msg":"----------------------------------------------------------------------"}
{"msg":" old ts: 1686852416732 \n zsb ts: 1686856016732 \n new ts: 1686856016961"}
{"msg":"----------------------------------------------------------------------"}
....
//可见每3600s更新下误差约为~230ms，可视为RTT时间
```



https://blog.csdn.net/kangweijian/article/details/79748563

https://www.kancloud.cn/aiot/zigbee/2482313

https://www.ti.com/lit/ug/swru191f/swru191f.pdf?ts=1683770171359&ref_url=https%253A%252F%252Fwww.google.com%252F







