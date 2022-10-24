---
title: "事务"
description: 学习
date: 2022-10-20T02:37:49Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
  - DB
tags:
---
## State

![img](/images/Tt7.png)

https://www.geeksforgeeks.org/transaction-states-in-dbms/

## serializability

- Schedule(调度) – a sequences of instructions that specify the chronological order in which instructions of concurrent transactions are executed
- Serializability- Each transaction preserves database consistency
  - **conflict serializability** 
    - Read-Write conflict
    - Write-Read conflict
    - Write-Write conflict
  - **view serializability**
- **conflict equivalent**(过程一致)-  If a schedule S can be transformed into a schedule S’ by a series of swaps of non-conflicting instructions, we say that S and S’ are conflict equivalent
- **view equivalent** (READ一致):
  - same transaction to initial READ(Q)
  - same transaction to ifinal WRITE(Q)
  - must obey  Tj WRITE(Q) -> Ti READ(Q)
- **conflict/view serializable** - We say that a schedule S is conflict serializable if it is conflict equivalent to a serial schedule
  - ![image-20221019143143141](/images/image-20221019143143141.png)

- Every view serializable schedule that is not conflict serializable has **blind writes**

## PG(precedence graph)

https://unacademy.com/lesson/precedence-graph-method-for-testing-conflict-serializability/J1H5UXFM

- ![image-20221019144717004](/images/image-20221019144717004.png):![image-20221019144730422](/images/image-20221019144730422.png)
- If precedence graph is **acyclic**, it is **conflict serializable** ,  the **serializability order** can be obtained by a **topological sorting** of the graph
  - use Cycle-detection algorithms

![GATE & ESE - Precedence graph method for testing conflict serializability  Offered by Unacademy](/images/2.png)

- The precedence graph test for conflict serializability cannot be used directly to test for view serializability.
  - checking if a schedule is view serializable falls in the class of NP-complete problems

## Strict 2PL

## Recoverable Schedules

- **Recoverable schedule**: if have`Ti WRITE(Q) -> Tj READ(Q)` must have  `Ti commit - >Tj commit `, commit operation of Ti appears before the commit operation of Tj
- the following schedule is not recoverable ,is if T8 fails ,it need to abort T9 for atomicity

![image-20221019150844357](/images/image-20221019150844357.png)

- Cascading rollback – a single transaction failure leads to a series of transaction rollbacks.
- **Cascadeless schedules** — cascading rollbacks cannot occur ,Tj reads a data item previously written by Ti , the commit operation of Ti appears before the read operation of Tj, `Ti commit -> Tj READ(Q)`
  - Every cascadeless schedule is also recoverable



## Concurrency Control

- either conflict/view serializable

- recoverable and preferably cascadeless

- Different concurrency control protocols provide different tradeoffs between the amount of concurrency they allow and the amount of overhead that they incur.



## Levels of Isolation in ANSI SQL-92

http://blog.kongfy.com/2019/03/serializable/

https://www.cnblogs.com/kismetv/p/10331633.html

- **Serializable** — default 
- **Repeatable read** — only committed records to be read. 
  - However, a transaction may not be serializable – it may find some records inserted by a transaction but not find others. 
  - **phantom read**
- **Read committed** — only committed records can be read. 
  -  Successive reads of record may return different (but committed) values. 
  -  **Unrepeatable Read**
- **Read uncommitted** — even uncommitted records may be read. 
  - **dirty read**



![a576e8b77a5453f80d723d38894d4019.png](/images/a576e8b77a5453f80d723d38894d4019.png)

## Implementation of Isolation Levels

https://xie.infoq.cn/article/526912f56a0b2fc9991f44fa0

- Locking
  - Lock on whole database vs lock on items
  - Shared vs exclusive locks
- Timestamps
- Multiple versions and snapshot isolation



