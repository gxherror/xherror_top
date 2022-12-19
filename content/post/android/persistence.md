---
title: "持久化"
description: 学习
date: 2022-12-19T04:54:46Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
 - ANDROID
tags:
---
## 文件存储

```
import android.os.Environment;
public class File 
```



### 存储位置

```
Internal Storage	/
\--- App-specific directory data/data/{your.package.name}/
	\--- files、cache、db...
External Storage	/storage/emulated/0/
\--- App-specific directory Android/data/{your.package.name}/
	\--- files、cache
\--- Public directory	./
	\--- Standard: DCIM、Download、Movies
	\--- Others
```

<img src="/images/image-20221203113632961.png" alt="image-20221203113632961" style="zoom:67%;" />

```kotlin
Internal ⽬录
context.getFilesDir() 
context.getCacheDir() 
context.getDir(name, mode_private)

External ⽬录
1.权限申请
2.可⽤性检查
Environment.getExternalStorageState();
应⽤私有⽬录： 
	file⽬录: context.getExternalFilesDir(String type) 
	cache⽬录：context.getExternalCacheDir() 
公共⽬录： 
	标准⽬录：Environment.getExternalStoragePublicDirectory(String type) 
	根⽬录：Environment.getExternalStorageDirectory()

卸载后保留的文件需要储存杂公共区域

```



<img src="/images/image-20221112135731471.png" alt="image-20221112135731471" style="zoom: 50%;" />

文件存储是Android中最基本的数据存储方式，它不对存储的内容进行任何格式化处理，所有数据都是原封不动地保存到文件当中的，因而它比较适合存储一些简单的文本数据或二进制数据。如果你想使用文件存储的方式来保存一些较为复杂的结构化数据，就需要定义一套自己的格式规范，方便之后将数据从文件中重新解析出来。

```kotlin
//默认存储位置/data/data/<package name>/files
//Context类提供的方法
protected fun saveUseFile(inputText:String){
	try {
		//MODE_PRIVATE为替代，MODE_APPEND为附加
		val fd=openFileOutput("data",Context.MODE_PRIVATE)
		//BufferIO减少IO时间
		val writer=BufferedWriter(OutputStreamWriter(fd))
		//use会自动调用close()
		writer.use {
			it.write(inputText)
		}
	}catch (e:IOException){
		e.printStackTrace()}
}

protected fun loadFromFile(fileName:String):List<String>{
	lateinit var result:List<String>
	try {
		val fd=openFileInput(fileName)
		val reader=BufferedReader(InputStreamReader(fd))
		reader.use {
			result=it.readLines()
		}
	} catch (e:IOException){
		e.printStackTrace()
	}
	return result
}
```

## SharedPreferences

SharedPreferences是使用键值对的方式来存储数据的,如果存储的数据类型是整型，那么读取出来的数据也是整型的；如果存储的数据是一个字符串，那么读取出来的数据仍然是字符串。

- Context类中的`getSharedPreferences()`方法,接收两个参数
- Activity类中的`getPreferences()`方法,会自动将当前Activity的类名作为 SharedPreferences的文件名
- ⼀次性读取到内存,提供同步(commit())和异步(apply())两种写回⽂件的⽅式
- 适合场景：⼩数据,每次写⼊均为**全量写⼊**
- 禁⽌⼤数据存储在 SharedPreference 中，导致 ANR（Application Not Responding）
- MMKV,mmap 内存映射的 key-value 组件

```kotlin
//TODO:type T
protected fun saveStringUseSP(key:String,inputData:String){
	val prefs = getSharedPreferences("global",Context.MODE_PRIVATE).edit().run {
		putString(key,inputData)
		commit()
        //apply()
	}
}

protected fun loadStringFromSP(key:String):String{
	return getSharedPreferences("global",Context.MODE_PRIVATE).run {
		getString(key,"")!!
	}
}
```

储存文件格式

```
<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<map>
    <string name="data1">TTT</string>
</map>
```

### 简化SP

```
//利用扩展高阶函数
protected fun SharedPreferences.save(block:SharedPreferences.Editor.()->Unit){
	edit().run {
		block()
		commit()
	}
}
```

Google的KTX库就包含了多种简化用法`contentValuesOf()`，`SharedPreferences.edit{}`等等

```
dependencies {
    implementation 'androidx.activity:activity-ktx:1.6.0'
}
```


### hash加密

明显明文储存密码不是一种明智的选择，采用HmacSHA256加密套件

导入加密用库

```
dependencies {
    // https://mvnrepository.com/artifact/commons-codec/commons-codec
    implementation 'commons-codec:commons-codec:1.15'
    ......
}
```

加密实现

```kotlin
import org.apache.commons.codec.binary.Hex
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec
//SALT为加盐值，key为任意长密钥，推荐为64B
fun createSignature(rawSecret:String,key:String):String{
    val saltedSecret=rawSecret+ SALT
    val sha256Hmac=Mac.getInstance("HmacSHA256")
    val secretKey=SecretKeySpec(key.toByteArray(),"HmacSHA256")
    sha256Hmac.init(secretKey)
    return Hex.encodeHexString(sha256Hmac.doFinal(saltedSecret.toByteArray()))
}
```

### 实现记住密码

```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
	val sp=getSharedPreferences("global", MODE_PRIVATE)
	var isCorrection=sp.getBoolean("rememberPassword",false)
	super.onCreate(savedInstanceState)
	val binding = ActivitySignInBinding.inflate(layoutInflater) //FirstLayoutBinding bind to name
	setContentView(binding.root)
	binding.activitySignInAccountEdit.setText(sp.getString("account",""))
	if (isCorrection){
		binding.activitySignInPasswordEdit.setText(sp.getString(sp.getString("account",""),""))
	}
	binding.activitySignInButton.setOnClickListener {
		if (!isCorrection){
			val requireSecret=sp.getString(binding.activitySignInAccountEdit.text.toString(),"")
			val inputSecret=
				CommomUtils.createSignature(binding.activitySignInPasswordEdit.text.toString(), KEY)
			if (requireSecret==inputSecret) {
				if (binding.activitySignInCheckBox.isChecked) {
					isCorrection = true
					sp.save { putBoolean("rememberPassword",true) }
				}
				startActivity(Intent(this, SenderActivity::class.java))
			}else{
				Toast.makeText(this,"ERROR",Toast.LENGTH_SHORT).show()
			}
		}else{startActivity(Intent(this, SenderActivity::class.java))}
	}
}
```

## SQLite数据库存储

- SQLiteOpenHelper是一个抽象类，SQLiteOpenHelper中有两个抽象方法：onCreate()和onUpgrade()。我们必须在自己的帮助类里重写这两个方法。
- getReadableDatabase()和getWritableDatabase()
- onCreate**仅在数据库不存在时调用**，onUpgrade在Version改变时调用
- IO 操作不能放在 UI 绘制线程
- SQLiteDatabase 建议设置成单例
- 多次频繁操作，可以通过事务完成，减少 IO 次数

```kotlin
class MyDatabaseHelper(val context: Context, name: String, version: Int):
	SQLiteOpenHelper(context, name, null, version) {
	...
override fun onCreate(db: SQLiteDatabase?) {
        db?.execSQL(createBook)
        db?.execSQL(createCategory)
    }

    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
        if (oldVersion<=1){db?.execSQL(createCategory)}
        if (oldVersion<=2){db?.execSQL("ALTER TABLE Book ADD COLUMN category_id integer")}
    }

val dbHelper = MyDatabaseHelper(this, "BookStore.db", Version)
val db=dbHelper.writableDatabase
```

- CRUD操作
  - Android原生API`db.insert(...)`
  - SQL语法`db.execSQL("insert into Book values(?, ?, ?, ?)",arrayOf("x", "y", "454", "16.96"))`，`val cursor = db.rawQuery("select * from Book", null)`
  - ORM模型Mybatis/Ktorm

### 事务transaction

```kotlin
val db=dbHelper.writableDatabase.run {
	beginTransaction()
	try {
		delete("Book",null,null)
		insert("Book",null,ContentValues().apply {
			put("name","QQQ")
			put("author","xherror")
			put("pages","122")
			put("price",16.55) })
		execSQL("INSERT INTO Book(name,author,pages,price) VALUES(?,?,?,?)", arrayOf("QWQ","xherror","654","12.45"))
	}catch (e:java.lang.Exception){
		e.printStackTrace()
	}finally {
		endTransaction()
	}
}
```

![image-20221112140807530](/images/image-20221112140807530.png)

## Room Library

SQLite APIs的痛点：
○ SQL 语句⽆编译时校验，容易出错，调试成本⼤。
○ 表结构变化后需⼿动更新，并处理升级逻辑。
○ 使⽤⼤量模板代码从SQL查询向JavaBeans转换。



○ JetPack 中的库
○ 对数据库的使⽤做了⼀层抽象
○ 通过 APT （Annotation Processing Tool）减少模版代码



Room is a Database Object Mapping library that makes it easy to access database on Android applications

https://developer.android.com/training/data-storage/room

```kotlin
@androidx.room.Database(entities = [EntityItem::class], version = 1,exportSchema = false)
abstract class AppDatabase : RoomDatabase() {
    abstract fun itemDao(): ItemDao
}

@androidx.room.Entity
data class EntityItem (
    @PrimaryKey(autoGenerate = true)var id: Int=0,
    @ColumnInfo(name = "name") var name: String,
    @ColumnInfo(name = "category") var category: String,
)

@androidx.room.Entity
data class TestItem (
    @PrimaryKey(autoGenerate = true) var id: Int=-1,
    @ColumnInfo(name = "name") var name: String
)

@Dao
interface ItemDao {
    @Insert
    fun insertItems(vararg items: EntityItem)

    @Delete
    fun deleteItems(vararg items: EntityItem)

    @Update
    fun updateItems(vararg items: EntityItem)

    @Query("SELECT * FROM EntityItem WHERE category = :category")
    fun getSpecialCategory(category:String): List<EntityItem>

    @Query("SELECT * FROM EntityItem")
    fun getAll(): List<EntityItem>

    @Query("SELECT * FROM EntityItem WHERE ownerAccount = :ownerAccount")
    fun getMyItems(ownerAccount: String): List<EntityItem>
}


 fun init(name:String, version:Int){
        db = Room.databaseBuilder(
            MyApplication.getContext(),
            AppDatabase::class.java, DATABASE_NAME
        ).allowMainThreadQueries().build()
        itemDao = db.itemDao()
    }

fun insertItem( item: EntityItem){
        itemDao.insertItems(item)
    }
```

