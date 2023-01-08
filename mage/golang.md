

## day01



#### go常用命令

go run 
go build
go test	//单元测试
go tool	//go程序追踪、调试
go mod init
go mod tidy	//在go.mod文件中添加Import的包（未存在go.mod中的包）
go fmt	//格式化文本到go格式
go get -u //下载包


#### godoc
安装godoc第三方包，然后本地启动http服务，访问这个嗠，可以将包的注释以html形式展现。
PS D:\share\study\day01\first\const> go get golang.org/x/tools/cmd/godoc
PS D:\share\study\day01\first\const> godoc -http :6060
using module mode; GOMOD=D:\share\study\day01\first\go.mod



##  day02




### slice

#### append
1. 切片相对于数组最大的特点就是可以追加元素，可以自动扩容
2. 追加的元素放到预留的内存空间里，同时len加1
3. 如果预留空间已用完，则会重新申请一块更大的内存空间，把capacity变成之前的2倍（cap<1024）或1.25倍（cap>1024）。把原内存空间的数据拷贝过来，在新内存空间上执行append操作。

#### 截取子切片
* s := make([]int, 3, 5)	//len=3, cap=5
* sub_slice := s[1:3]		//len=2, cap=4
1. 刚开始，子切片和母切片共享底层的内存空间(底存数组)，修改子切片会反映到母切片上，在子切片上执行append会把新元素放到母切片预留的内存空间上。
2. 当子切片不断执行append，耗完了母切片预留的内存空间，子切片跟母切片就会发生内存分享，此后两个切片没有任何关系。
```
func sub_slice() {
	// 子切片，底层是数组，数组中每个元素大小为8个byte，每个元素都有一个内存地址
	arr := make([]int, 3, 5)
	crr := arr[0:2] //0，1两个元素
	fmt.Println(arr)
	crr[1] = 8
	fmt.Println(arr[1])
	crr = append(crr, 9) //第3个位置
	fmt.Println(arr[2])
	crr = append(crr, 9)                    //第4个位置
	crr = append(crr, 9)                    //第5个位置
	fmt.Println(arr)                        //此时其实是 [0 8 9 9 9]，只是len为3所以输出为3个元素
	fmt.Printf("%p %p\n", &arr[0], &crr[0]) //此时内存地址还是一样

	// 内存分离
	crr = append(crr, 9) //第6个位置，此时crr已经跟arr内存分离，crr会开辟一个新的内存空间，并复制之前内存的值到新内存空间
	crr[1] = 4
	fmt.Println(arr[1])                     //此时输出的还是8，crr不会再影响arr了
	fmt.Printf("%p %p\n", &arr[0], &crr[0]) //内存地址已经不一样了
}
```

#### 切片传参
* go语言函数传参，传的都是值，即传切片会把切片的{arrayPointer, len, cap}这3个字段拷贝一份传进来
* 由于传的是底层数组的指针，所以可以直接修改底层数组里面的元素
```
func update_slice(arr []int) {
	arr[0] = 100
}

func main() {
	crr := []int{2, 3, 4}
	update_slice(crr)
	fmt.Println(crr[0])	//输出为100
}
```

### map
1. 底层还是hash table，无序的
2. 新建1个map，map容量为5，就是slot为5，然后对存取里面的“key”进行unicode，然后对unicode进行对5取余，当有多个key取余数都一样，则此时在同一个slot的地方将会存取两个key（被称为链表），当下次要查找这其中某个key时，步骤是这样的{1首先对要查找的key取余，到达链表。
3. 然后对这个链表进行遍历找到自己要查询的key[此步骤遍历会导致性能下降，所以建议避免形成链表，将map的容量初始化为一个合理的值，如果map容量满了将会重新开辟内存空间，此步骤也会造成开销] }
``` var m = make(map[string]int, 5) ```

```
package main

import "fmt"

func main() {
	var m map[string]int
	// fmt.Println(len(m)) //长度为0
	// m = make(map[string]int)
	// fmt.Println(len(m)) //长度为0
	// m = make(map[string]int, 10)
	// fmt.Println(len(m)) //长度为0
	m = map[string]int{"A": 3, "B": 2}
	// fmt.Println(len(m)) //长度为2
	// m["D"] = 18         //长度为3
	// fmt.Println(len(m)) //长度为2

	// delete(m, "B")
	// for key, value := range m {
	// 	fmt.Printf("key=%s, value=%d\n", key, value)
	// }

	key := "F"
	v, ok := m[key]
	if ok {
		fmt.Println(v)
	} else {
		fmt.Printf("key %s not exists.", key)
	}
}
```

### channel
1. 通道的cap在初始化后，是不能改变的，cap的值是make时的值，len()表示通道的值的长度
2. 当通道的len等于cap时，不能在往里sent值，因为会报错。可以先recv一个值，然后再放一个值。
3. 插入数据是sent，取出数据是recv
4. channel中如果容量满了再放值，则会阻塞，如果channel没有了再取值，也会阻塞。
```
package main

import "fmt"

func main() {
	var ch chan int
	fmt.Printf("channel is nil %t\n", ch == nil)
	fmt.Printf("len of ch is %d\n", len(ch))

	ch = make(chan int, 10)
	fmt.Printf("len of ch is %d\n", len(ch))
	fmt.Printf("cap of ch is %d\n", cap(ch))

	ch <- 1
	ch <- 2
	ch <- 2
	fmt.Printf("len of ch is %d\n", len(ch))

	L := len(ch)
	//遍历管道(环形队列)1, 可以不close()管道，但是建议先关闭close管道再取
	for i := 0; i < L; i++ {
		v := <-ch
		fmt.Println(v)
	}
	// close(ch)	//必须先关闭管道再遍历，特别是下面这种遍历方法
	// for ele := range ch {
	// 	fmt.Println(ele)
	// }
	fmt.Println(len(ch)) //当取出后，管道长度将为0
}
```

### 引用类型
1. slice(会自动扩容)、map(会自动扩容)和channel(不能扩容)是go语言里面的3种引用类型，都可以通过make函数来进行初始化（申请分配内存）
2. 因为它们都包含一个指向底层数据结构的指针，所以称之为“引用”类型
3. 引用类型未初始化时都是nil, 可以对它们执行len()函数，返回0





## day03



### 流程控制

#### if
```
package main

import (
	"fmt"
	"time"
)

func goo() {
	m := make(map[int]string, 10)
	m[1] = "abc"
	if value, exists := m[2]; exists {	//value是if块的局部变量，放在外面则是整个goo函数的变量
		fmt.Println(value)
	} else {
		fmt.Println("key 2 not exists!")
	}

}

func if_nest() {
	now := time.Now()
	weekday := now.Weekday()
	hour := now.Hour()
	fmt.Println(weekday, hour)
	if weekday.String() != "Saturday" && weekday.String() != "Sunday" {
		if hour <= 9 && hour >= 7 {
			fmt.Println("not go")
		} else {
			fmt.Println("go")
		}
	} else {
		fmt.Println("go")
	}
}

func main() {
	goo()
	if_nest()
}
```

#### switch
```
package main

import (
	"fmt"
)

func basic() {
	color := "yellow"
	switch color {
	case "red": // if color == "red"
		fmt.Println("color is red")
	case "green": // if color == "green"
		fmt.Println("color is green")
	case "black": // if color == "black"
		fmt.Println("color is black")
	default: // else
		fmt.Println("都不是")
	}
}

func add(n int) int {
	return n + 1
}

func sub(n int) int {
	return n - 1
}

func pos(n int) bool {
	return n > 0
}
func expression() {
	var a int = 10
	const B = 11
	switch add(a) {
	default:
		fmt.Println("都不是")
	case 5:
		fmt.Println("sum is 5")
	// case 11:
	// 	fmt.Println("sum is 11")
	// case sub(12):
	// 	fmt.Println("sum is 12 - 1")
	case 7, 8, B:
		fmt.Println("sum is 7 or 8 or B")
	case 12:
		fmt.Println("sum is 12")
	}
}

func switch_condition() {
	switch {
	case 5 > 8:
		fmt.Println("5 > 8")
	case add(5) == 9:
		fmt.Println("add(5) == 9")
	case pos(5):
		fmt.Println("5 > 0")
	}
}

func main() {
	basic()
	expression()
	switch_condition()
}
--- fallthrough
func fall(age int) {
	switch {
	case age > 50:
		fmt.Println("当总统")
		fallthrough // 意为执行到这里还要往下执行一次，可以配置多次
	case age > 25:
		fmt.Println("生孩子")
		fallthrough // 意为执行到这里还要往下执行一次，可以配置多次
	case age > 22:
		fmt.Println("结婚")
	case age > 18:
		fmt.Println("开车")
	}
}

func main() {
	fall(60)
}
--- switch type
func switch_type() {
	var num interface{} = 6.5 // interface类型Java的Object对象，所有类型的父类
	switch num.(type) {       // 判断num的具体类型，x.(type)只能放到switch使用
	case int:
		fmt.Println("num is int")
	case float64:
		fmt.Println("num is float64")
	case byte, string, bool:
		fmt.Println("num is byte or string or bool")
	default:
		fmt.Println("以上猜测都不对")
	}
	// 将类型赋予变量
	switch value := num.(type) {
	case int:
		fmt.Printf("num is %d\n", value)
	case float64:
		fmt.Printf("num is %.2f\n", value)
	case byte, string, bool:
		fmt.Printf("num is %v\n", value)
	default:
		fmt.Println("num是其它类型")
	}
	// 等价于上面那个switch
	switch num.(type) {
	case int:
		value := num.(int)	//跟x.type一样只能switch中使用
		fmt.Printf("num is %d\n", value)
	case float64:
		value := num.(float64)
		fmt.Printf("num is %.2f\n", value)
	case byte:
		value := num.(byte)
		fmt.Printf("num is %d\n", value)
	default:
		fmt.Println("num是其它类型")
	}
}

func main() {
	switch_type()
}
```



#### for循环

1. 初始化变量可以放在for上面
2. 后续操作可以放在for块内部
3. 只有条件判断时，前后的分别可以不要，否则都需要分号
4. for{}是一个无限循环，相当于while true

```
package main

import "fmt"

func basic() {
	arr := [...]int{1, 2, 3, 4, 5, 6}
	// for i := 0; i < len(arr); i++ {
	// 	fmt.Printf("%d %d\n", i, arr[i])
	// }
	// fmt.Println("等价============")
	// for i := 0; i < len(arr); {
	// 	fmt.Printf("%d %d\n", i, arr[i])
	// 	i++
	// }
	// fmt.Println("等价============")
	// i := 0
	// for i < len(arr) {
	// 	fmt.Printf("%d %d\n", i, arr[i])
	// 	i++
	// }

	for sum, i := 0, 0; i < len(arr) && sum < 100; sum, i = sum+arr[i], i+1 {
		fmt.Printf("sum=%d\n", sum)
	}
}

func main() {
	basic()
}
--- for range
1. 遍历数组或切片
	for i, ele := range arr
2. 遍历string
	for i, ele := range "我会唱ABC"		//ele是rune类型
3. 遍历map, go不保证遍历的顺序
	for key, value := range m
4. 遍历channel, 遍历前一定要先close
	for ele := range ch
5. for range拿到的是数据的拷贝
---
func for_range() {
	arr := [...]int{1, 2, 3, 4, 5, 6}
	str := "我会唱ABC"

	fmt.Println(len(arr))
	for i, ele := range arr {
		fmt.Printf("%d %d\n", i, ele)
	}
	fmt.Println("============")

	fmt.Println(len(str)) //以byte计算长度
	for i, ele := range str {
		fmt.Printf("%d %c\n", i, ele)
	}
	fmt.Println("============")
	brr := []byte(str)
	fmt.Println(len(brr)) //以byte计算长度
	for i, ele := range brr {
		fmt.Printf("%d %d\n", i, ele)
	}
	fmt.Println("============")

	m := map[int]int{1: 1, 2: 2, 3: 3, 4: 4, 5: 5}
	for key, value := range m {
		fmt.Printf("%d %d\n", key, value)
	}
	fmt.Println("============")
	for key, value := range m { //输出最先最后不一样，但是元素之间的连接顺序是一样的
		fmt.Printf("%d %d\n", key, value)
	}
	fmt.Println("============")

	ch := make(chan int, 10)
	for i := 0; i < 10; i++ {
		ch <- i
	}
	close(ch)
	for ele := range ch {
		fmt.Println(ele)
	}
}
func main() {
	for_range()
}
```

#### break和continue

1. break与continue用于控制 for循环的代码流程，并且只针对最靠近自己的外层for循环
2. break: 退出for循环，且本轮break下面的代码不再执行
3. continue: 本轮continue下面的代码不再执行，进入for循环的下一轮

```
package main

import "fmt"

func break_for() {
	arr := []int{1, 2, 3, 4, 5}
	for i, ele := range arr {
		fmt.Println(i, ele)
		if i > 2 {
			break
		}
		fmt.Printf("第%d行\n", i+1)
	}
}

func continue_for() {
	arr := []int{1, 2, 3, 4, 5}
	for i, ele := range arr {
		fmt.Println(i, ele)
		if i > 2 {
			continue
		}
		fmt.Printf("第%d行\n", i+1)
	}
}

func complex_break_continue() {
	const SIZE = 5
	arr := [SIZE][SIZE]int{{1, 2, 3, 4, 5}, {1, 2, 3, 4, 5}, {1, 2, 3, 4, 5}, {1, 2, 3, 4, 5}, {1, 2, 3, 4, 5}}
	for i := 0; i < SIZE; i++ {
		fmt.Printf("第%d行\n", i)
		if i%2 == 1 {
			for j := 0; j < SIZE; j++ {
				fmt.Printf("第%d列\n", j)
				if arr[i][j]%2 == 0 {
					continue
				}
				fmt.Printf("将要第%d列\n", j+1)
			}
			break //只跳出自己所在的for循环
		}
	}
}

func main() {
	// break_for()
	// continue_for()
	complex_break_continue()
}
```

#### goto与Label

break、continue与Label

1. break、continue与Label结合使用可以跳转到更外层的for循环
2. continue和break针对的Label必须写在for前面，而goto可以针对任意位置的Label

```
案例1：
var i int = 4
MY_LABEL:
	i += 3
	fmt.Println(i)
	goto MY_LABEL  //返回定义MY_LABEL的那一行，把代码再执行一遍（会进入一个无限循环）
	
案例2：
if i%2 == 0{
	goto L1
} else {
	goto 2
}
L1: //后定义Label
	i += 3
L2:	//Lable定义后必须在代码的某个地方被使用
	i *= 3
	
案例3：	//退出for循环，实现break的功能，甚至更强大
for i := 0; i < SIZE; i++ {
L2:
	for j := 0; j < SIZE; j++ {
		goto L1:	//goto可以跳出指定的位置，不受多层for循环限制，而break会受for循环层次限制
	}
}
L1: 
	xxx

代码：
package main

import "fmt"

func basic() {
	var i int = 4
abc:
	i += 3
	i *= 4
	fmt.Println(i)
	if i > 200 {
		return
	}
	goto abc
}

func if_goto() {
	var i int = 4
	if i%2 == 0 {
		goto L1 //会走到L1，完成L1后还会继续L2
	} else {
		goto L2
	}
L1:
	i += 3
	fmt.Println(i)
L2:
	i *= 3
	fmt.Println(i)

}

func main() {
	basic()
	if_goto()
}
```



#### 结构体

1. 结构体创建、访问与修改
2. 结构体指针
3. 结构体嵌套
4. 深拷贝与浅拷贝    



##### 1. 结构体创建、访问与修改

###### 1. 1 定义结构体

```
package main

import (
	"fmt"
	"time"
)

type User struct {
	id            int
	Score         float64
	name, address string
	enrollment    time.Time
}

func main() {
	var ws User
	fmt.Printf("id %d, Score %g, name [%s], address [%s], enrollment %v\n", ws.id, ws.Score, ws.name, ws.address, ws.enrollment)
	ws = User{Score: 100, name: "Jack"}
	ws.Score = 93.5
	ws.enrollment = time.Now()

	a := ws.id + 24
	fmt.Printf("a=%d\n", a)

}
```

###### 1.2 成员函数（方法）

```
package main

import (
	"fmt"
	"time"
)

type User struct {
	id            int
	Score         float64
	name, address string
	enrollment    time.Time
}

func (user User) hello(man string) string {
	return "hello" + man + ", I'm" + user.name
}

func hello(man string, user User) string {
	return "hello" + man + ", I'm" + user.name
}

func main() {
	var ws User
	ws = User{Score: 100, name: "Jack"}
	fmt.Println(hello("jack", ws))
	fmt.Println(ws.hello("jack"))
}
```

###### 1.3 匿名结构体

```
#自定义结构体
type User struct {
	id int
	name string
	addr string
	tel string
}
var user User = User{1, "str1", "str2", "str3"}

#匿名结构体，只使用一次
var user struct {
	id int
	name string
	addr string
	tel string
}
user =  struct {
	id int
	name string
	addr string
	tel string
}{10, "str1", "str2", "str3"}
或者
var user = struct {
	id int
	name string
	addr string
	tel string
}{10, "str1", "str2", "str3"}

#结构体中含有匿名成员
type Student struct {
	Id int
	string //匿名字段
	float32 //直接使用数据类型作为字段名，所以匿名字段中不能出现重复的数据类型
}
var stu = Student{Id: 1, string: "zcy", float32: 79.5}
fmt.Printf("anonymous_member string member=%s float member=%f\n", stu.string, stu.float32)

```



##### 2. 结构体指针

###### 2.1 创建结构体指针

```
var u User
user := &u //通过取址符&得到指针
user = &User{ //直接创建结构体指针
    Id: 3, Name: "zcy", addr: "beijing",
}
user = new(User) //通过new()函数实体化一个结构体，并返回其指针

```

###### 2.2 构造函数

```
//构造函数。返回指针是为了避免值拷贝
func NewUser(id int, name string) *User {
	return &User{
		Id: id,
		Name: name,
		addr: "China",
		Score: 59,
	}
}
```

```
// 案例
package main
import "fmt"

type Student struct {
	Name string
	string
	int
}

func NewStudent(name string, city string, age int) *Student {
	return &Student{name, city, age}
}

func main() {
	stu := NewStudent("jack", "ShangHai", 28)
	fmt.Println(*stu)
}

```

###### 2.3 方法接收指针

```
//user传的是值，即传的是整个结构体的拷贝。在函数里修改结构体不会影响原来的结构体
func hello(u user, man string) {
    u.name = "杰克"
    fmt.Println("hi " + man + ", my name is " + u.name)
}
//传的是user指针，在函数里修改user的成员会影响原来的结构体
func hello2(u *user, man string) {
    u.name = "杰克"
    fmt.Println("hi " + man + ", my name is " + u.name)
}

//把user理解为hello()的参数，即hello(u user, man string)
func (u user) hello(man string) {
    u.name = "杰克"
    fmt.Println("hi " + man + ", my name is " + u.name)
}
//可以理解为hello2(u *user, man string)
func (u *user) hello2(man string) {
    u.name = "杰克"
    fmt.Println("hi " + man + ", my name is " + u.name)
}

```

##### 3. 结构体嵌套

###### 3.1 结构体嵌套

```
type user struct {
    name string
    sex byte
}
type paper struct {
    name string
    auther user //结构体嵌套
}
p := new(paper)
p.name = "论文标题"
p.auther.name = "作者姓名"
p.auther.sex = 0
type vedio struct {
    length int
    name string
    user//匿名字段,可用数据类型当字段名
}

```

###### 3.2 字段名冲突

```
v := new(vedio)
v.length = 13
v.name = "视频名称"
v.user.sex = 0 //通过字段名逐级访问
v.sex = 0 //对于匿名字段也可以跳过中间字段名，直接访问内部的字段名
v.user.name = "作者姓名" //由于内部、外部结构体都有name这个字段，名字冲突了，所以需要指定中间字段名

```



#### 4 深拷贝与浅拷贝

###### 4.1 拷贝

```
// 示例1
type User struct {
	Name string
}
type Vedio struct {
	Length int
	Author User
}

vedio1 := Vedio{25, "吴承恩"}
vedio2=vedio1	//赋值拷贝

// 示例2
type User struct {
	Name string
}
type Vedio struct {
	Length int
	Author *User	//为指针结构体，后面vedio1和vedio2无论哪个更改都会生效
}
vedio1 := Vedio{Length: 25, Author: new(User)}
vedio1.Author.Name = "吴承恩"
vedio2=vedio1	//赋值拷贝

```

###### 4.2 深拷贝与浅拷贝

```
深拷贝，拷贝的是值，比如Vedio.Length
浅拷贝，拷贝的是指针，比如Vedio.Author
深拷贝开辟了新的内存空间，修改操作不影响原先的内存
浅拷贝指向的还是原来的内存空间，修改操作直接作用在原内存空间上

```

###### 4.3 结构体slice传参

```
users := []User{{Name: "康熙"}}
func update_users(users []User) {
    users[0].Name = "光绪"
}
传slice，对slice的3个字段进行了拷贝，拷贝的是底层数组的指针，所以修改底层数组的元素会反应到原数组上
type slice struct {
    array unsafe.Pointer
    len int
    cap int
}
```



## day04



### Go语言函数基础

* 函数的基本形式
* 匿名函数
* 闭包
* 延迟调用defer
* 异常处理



#### 函数的基本形式

```
## 形参与实参
//a,b是形参，形参是函数内部的局部变量，实参的值会拷贝给形参
func argf(a int, b int) { //注意大括号{不能另起一行
	a = a + b //在函数内部修改形参的值，实参的值不受影响
}
var x, y int = 3, 6
argf(x, y) //x,y是实参
形参可以有0个或多个
参数类型相同时可以只写一次，比如argf(a,b int)


## 参数传指针
如果想通过函数修改实参，就需要指针类型
func argf(a, b *int) { 
*a = *a + *b
*b = 888
}
var x, y int = 3, 6
argf(&x, &y)


## 传引用和传引用的指针
slice、map、channel都是引用类型，它们作为函数参数时其实跟普通struct没什么区别，都是对struct内部的各个字段做一次拷贝传到函数内部
func slice_arg_1(arr []int) { //slice作为参数，实际上是把slice的arrayPointer、len、cap拷贝了一份传进来
        arr[0] = 1 //修改底层数据里的首元素
        arr = append(arr, 1) //arr的len和cap发生了变化，不会影响实参
}


## 函数返回值
可以返回0个或多个参数
可以在func行直接声明要返回的变量
return后面的语句不会执行
无返回参数时return可以不写
func returnf(a, b int) (c int) { //返回变量c已经声明好了
a = a + b
c = a //直接使用c
return //由于函数要求有返回值，即使给c赋过值了，也需要显式写return
}


## 不定长参数
func variable_ength_arg(a int, other ...int) int { 
sum := a
for _, ele := range other {//不定长参数实际上是slice类型
	sum += ele
}
fmt.Printf("len %d cap %d\n", len(other), cap(other))
return sum
}
variable_ength_arg(1)
variable_ength_arg(1,2,3,4)

#append函数接收的就是不定长参数
arr = append(arr, 1, 2, 3)
arr = append(arr, 7)
arr = append(arr)
slice := append([]byte("hello "), "world"...) ...自动把"world"转成byte切片，等价于[]byte("world")...
slice2 := append([]rune("hello "), []rune("world")...) //需要显式把"world"转成rune切片


## 递归函数
func Fibonacci(n int) int {
if n == 0 || n == 1 {
	return n //凡是递归，一定要有终止条件，否则会进入无限循环
}
return Fibonacci(n-1) + Fibonacci(n-2) //递归调用函数自身
}

#递归函数案例
//计算斐波那契数列的第n个值
//
//斐波那契数列以如下被以递推的方法定义： F (0)=0， F (1)=1, F (n)= F (n - 1)+ F (n - 2)
//
//斐波那契数列前10个数为：0，1，1，2，3，5，8，13，21，34
func Fibonacci(n int) int {
	if n == 0 || n == 1 {
		return n //凡是递归，一定要有终止条件，否则会进入无限循环
	}
	return Fibonacci(n-1) + Fibonacci(n-2) //递归调用函数自身
}

```

#### 匿名函数

```
//匿名函数
var sum = func(a, b int) int {
	return a + b
}

func function_arg1(f func(a, b int) int, b int) int { //f参数是一种函数类型（函数类型看上去比较冗长）
	a := 2 * b
	return f(a, b)
}

type foo func(a, b int) int //foo是一种函数类型
func function_arg2(f foo, b int) int { //参数类型看上去乘洁多了
	a := 2 * b
	return f(a, b)
}
```

#### 闭包

•闭包（Closure）是引用了自由变量的函数

•自由变量将和函数一同存在，即使已经离开了创造它的环境

•闭包复制的是原对象的指针

```
package main

import "fmt"

//闭包（Closure）是引用了自由变量的函数。自由变量将和函数一同存在，即使已经离开了创造它的环境。
func sub() func() {
	i := 10
	fmt.Printf("%p\n", &i)
	b := func() {
		fmt.Printf("i addr %p\n", &i) //闭包复制的是原对象的指针
		i--                           //b函数内部引用了变量i
		fmt.Println(i)
	}
	return b //返回了b函数，变量i和b函数将一起存在，即使已经离开函数sub()
}

// 外部引用函数参数局部变量
func add(base int) func(int) int {
	return func(i int) int {
		fmt.Printf("base addr %p\n", &base)
		base += i
		return base
	}
}

func main() {
	b := sub()
	b()
	b()
	fmt.Println()

	tmp1 := add(10)
	fmt.Println(tmp1(1), tmp1(2)) //11,13
	// 此时tmp1和tmp2不是一个实体了
	tmp2 := add(100)
	fmt.Println(tmp2(1), tmp2(2)) //101,103
}

//go run function/closure/main.go

```

#### 延迟调用defer

•defer用于注册一个延迟调用（在函数返回之前调用）

•defer典型的应用场景是释放资源，比如关闭文件句柄，释放数据库连接等

•如果同一个函数里有多个defer，则后注册的先执行

•defer后可以跟一个func， func 内部如果发生panic，会把panic暂时搁置，当把其他defer执行完之后再来执行这个panic，panic之后的代码就不会再被执行了。

•defer后不是跟func，而直接跟一条执行语句，则相关变量在注册defer时被拷贝或计算

```
## defer执行顺序
func basic() {
fmt.Println("A")
defer fmt.Println(1) fmt.Println("B")
//如果同一个函数里有多个defer，则后注册的先执行
defer fmt.Println(2)
fmt.Println("C")
}

## defer func
func defer_exe_time() (i int) {
i = 9
defer func() { //defer后可以跟一个func,defer中的func不会先赋值，只有在被调用执行时才赋值
	fmt.Printf("i=%d\n", i) //打印5，而非9
}()
defer fmt.Printf("i=%d\n", i) //变量在注册defer时被拷贝或计算
return 5 //先返回5给变量i，等defer结束后再执行return退出 
}


/*
	defer典型的应用场景是释放资源，比如关闭文件句柄，释放数据库连接等
*/
package main

import (
	"fmt"
)

func basic() {
	fmt.Println("A")
	defer fmt.Println(1) //defer用于注册一个延迟调用（在函数返回之前调用）
	fmt.Println("B")
	defer fmt.Println(2) //如果同一个函数里有多个defer，则后注册的先执行
	fmt.Println("C")
	defer fmt.Println(3)
	fmt.Println("D")
}

func defer_exe_time() (i int) {
	i = 9
	defer func() { //defer后可以跟一个func
		fmt.Printf("first i=%d\n", i) //打印5，而非9。充分理解“defer在函数返回前执行”的含义，不是在“return语句前执行defer”
	}()
	defer func(i int) {
		fmt.Printf("second i=%d\n", i) //打印9
	}(i)
	defer fmt.Printf("third i=%d\n", i) //defer后不是跟func，而直接跟一条执行语句，则相关变量在注册defer时被拷贝或计算
	return 5
}

func defer_panic() {
	defer fmt.Println(1)	//先注册后执行，堆，LIFO
	n := 0
	// defer fmt.Println(1 / n) //在注册defer时就要计算1/n，发生panic，第3个defer根本就没有注册。发生panic时首先会去执行已注册成功的defer，然后打印错误调用堆栈，最后exit(2)
	defer func() {
		fmt.Println(1 / n)   //defer func 内部发生panic，main协程不会exit，等外部其他注册成功的defer执行完成后再退出
		defer fmt.Println(2) //上面那行代码发生发panic，所以本行的defer没有注册成功
	}()
	defer fmt.Println(3)
}

func main() {
	basic()
	fmt.Println()
	defer_exe_time()
	fmt.Println()
	defer_panic()
}

//go run function/defer/main.go
```

#### 异常处理

```
## 异常机制
func divide(a, b int) (int, error) {// go语言没有try catch，它提倡返回error
if b == 0 {
	return -1, errors.New("divide by zero")
}
return a / b, nil
}
if res, err := divide(3, 0); err != nil {//函数调用方判断error是否为nil
        fmt.Println(err.Error())
}


## 自定义error
type PathError struct {    //自定义error
	path string
	op string
	createTime string
	message string
}
func (err PathError) Error() string {    //error接口要求实现Error() string方法
	return err.createTime + ": " + err.op + " " + err.path + " " + err.message
}


## panic
何时会发生panic:
	1. 运行时错误会导致panic，比如数组越界、除0
	2. 程序主动调用panic(error)
panic会执行什么：
	1. 逆序执行当前goroutine的defer链（recover从这里介入）
	2. 打印错误信息和调用堆栈
	3. 调用exit(2)结束整个进程

## recover
recover会阻断panic的执行
func soo(a, b int) {
	defer func() {
		//recover必须在defer中才能生效
		if err := recover(); err != nil {	fmt.Printf("soo函数中发生了panic:%s\n", err)
		}
	}()
	panic(errors.New("my error"))
}


## 异常处理代码
package main

import (
	"errors"
	"fmt"
	"time"
)

//自定义error
type PathError struct {
	path       string
	op         string
	createTime string
	message    string
}

func NewPathError(path, op, message string) PathError {
	return PathError{
		path:       path,
		op:         op,
		createTime: time.Now().Format("2006-01-02"),
		message:    message,
	}
}

//error接口要求实现Error() string方法
func (err PathError) Error() string {
	return err.createTime + ": " + err.op + " " + err.path + " " + err.message
}

func divide(a, b int) (int, error) {
	if b == 0 {
		return -1, errors.New("divide by zero")
	}
	return a / b, nil
}

func delete_path(path string) error {
	//如果文件路径不存在，就返回一个error；否则返回nil
	return NewPathError(path, "delete", "path not exists") //返回自定义error
}

func soo() {
	fmt.Println("enter soo")
	defer func() { //去掉这个defer试试，看看panic的流程
		//recover必须在defer中才能生效
		if err := recover(); err != nil {
			fmt.Printf("soo函数中发生了panic:%s\n", err)
		}
	}()
	fmt.Println("regist recover")
	defer fmt.Println("hello")
	n := 0
	_ = 3 / n //除0异常，发生panic，下一行的defer没有注册成功
	defer fmt.Println("how are you")
}

func main() {
	if res, err := divide(3, 0); err == nil {
		fmt.Println(res)
	} else {
		fmt.Println(err.Error())
	}
	fmt.Println()
	soo()
	fmt.Println("soo没有使main协程退出")
}

//go run function/panic/main.go
```





### Go语言接口编程



#### 接口的基本概念

```
## 接口的定义
//接口是一组行为规范的集合
type Transporter interface { //定义接口。通常接口名以er结尾
	//接口里面只定义方法，不定义变量
	move(src string, dest string) (int, error) //方法名 (参数列表) 返回值列表
	whistle(int) int //参数列表和返回值列表里的变量名可以省略
}


## 接口的实现
type Car struct { //定义结构体时无需要显式声明它要实现什么接口,一个struct可以同时实现多个接口
	price int
}
//只要结构体拥有接口里声明的所有方法，就称该结构体“实现了接口”
func (car Car) move(src string, dest string) (int, error) {
	return car.price, nil
}
func (car Car) whistle(n int) int {
	return n
}


## 接口的本质
接口值有两部分组成, 一个指向该接口的具体类型的指针和另外一个指向该具体类型真实数据的指针
car := Car{100}
var transporter Transporter
transporter = car
transporter.whistle(3)


## 接口的使用
func transport(src, dest string, transporter Transporter) error {
	 _,err := transporter.move(src, dest)
	return err
}
var car Car		//Car实现了Transporter接口
var ship Shiper	// Shiper实现了Transporter接口
transport("北京", "天津", car)	//会调用car对象的move方法
transport("北京", "天津", ship)	//会调用ship对象的move方法


## 接口的赋值
func (car Car) whistle(n int) int {…}//方法接收者用值
func (ship *Shiper) whistle(n int) int {…} //方法接收者用指针，则实现接口的是指针类型
car := Car{}
ship := Shiper{}
var transporter Transporter
transporter = car 	//whistle方法接收者是值，所以这里传值类型
transporter = &car     //whistle方法接收者是值，所以指针类型同样也实现了
transporter = &ship	  //whistle方法接收者是指针，所以这里只能传指针类型


# 代码
------
package main

// 定义Interface
type Transporter interface {
	move(string, string) (int, error)
	say(int)
}

type Humna interface {
	think(a int)
}

// 定义结构体实现接口
type Car struct {
}

func (Car) move(string, string) (int, error) {
	return 1, nil
}

func (Car) say(int) {

}

func (Car) think(a int) {

}

func foo(t Transporter) {

}

func main() {
	var t Transporter
	car := Car{}
	t = car
	t.say(2)

	foo(t)
	foo(car)

	var h Humna
	h = car
	h.think(4)
}
------
```

#### 接口嵌入

```
type Transporter interface {
	whistle(int) int
}
type Steamer interface {
	Transporter //接口嵌入。相当于Transporter接口定义的行为集合是Steamer的子集
	displacement() int
}

```

#### 空接口

```
空接口类型用interface{}表示，注意有{}
	var i interface{} 
空接口没有定义任何方法，因此任意类型都实现了空接口
	var a int = 5
	i = a
func square(x interface{}) {}该函数可以接收任意数据类型
slice的元素、map的key和value都可以是空接口类型

	sli := make([]interface{}, 5, 10)
	sli = append(sli, 1)
	sli = append(sli, "string")

	m := make(map[interface{}]interface{},5)
	m[1] = "string"
	m["str"] = 100
```

#### 类型断言

```
if v, ok := i.(int); ok {//i是interface, 若断言成功，则ok为true，v是具体的类型
	fmt.Printf("i是int类型，其值为%d\n", v)
} else {
	fmt.Println("i不是int类型")
}
当要判断的类型比较多时，就需要写很多if-else，更好的方法是使用switch i.(type)


## switch type
switch v := i.(type) {    //隐式地在每个case中声明了一个变量v
case int:  //v已被转为int类型
	fmt.Printf("ele is int, value is %d\n", v)
	//在 Type Switch 语句的 case 子句中不能使用fallthrough
case float64:      //v已被转为float64类型
	fmt.Printf("ele is float64, value is %f\n", v)
case int8, int32, byte: //如果case后面跟多种type，则v还是interface{}类型
	fmt.Printf("ele is %T, value is %d\n", v, v)
}
```



#### 面向接口编程

```
在框架层面全是接口
具体的实现由不同的开发者去完成，每种实现单独放到一个go文件里，大家的代码互不干扰
通过配置选择采用哪种实现，也方便进行效果对比

```



#### 作业

```
package main

import (
	"errors"
	"fmt"
)

// 1. 实现一个函数，接受若干个float64（用不定长参数），返回这些参数乘积的倒数，除数为0时返回error
func prod1(args ...float64) (float64, error) {
	var product float64 = 1.0
	for _, arg := range args {
		if arg == 0 {
			return product, errors.New("divide by zero")
		}
		product *= arg
	}
	return 1.0 / product, nil
}

// 2. 上题用递归函数实现
func prod(args ...float64) (float64, error) {
	if len(args) == 0 {
		return 0, errors.New("args is null")
	}
	first := args[0]
	if first == 0 {
		return 1.0, errors.New("divide by zero")
	}
	if len(args) == 1 {
		return 1.0 / first, nil
	}
	remain := args[1:]
	result, err := prod(remain...)
	if err != nil {
		return 1, err
	} else {
		return 1.0 / first * result, nil
	}

}

// 3. 定义两个接口：鱼类和爬行动物，再定义一个结构体：青蛙，同时实现上述两个接口
//定义鱼类接口
type Fisher interface {
	Swin()
}

//定义爬行动物接口
type Crawler interface {
	Craw()
}

type Frog struct {
}

func (Frog) Swin() {}
func (Frog) Craw() {}

// 4. 实现函数func square(num interface{}) interface{}，计算一个interface{}的平方，
// interface{}允许是4种类型：float32、float64、int、byte

func square(num interface{}) interface{} {
	// return num * num		// 空接口是不能跟空接口相乘的
	switch v := num.(type) {
	case int:
		return v * v
	case float32:
		return v * v
	case float64:
		return v * v
	case byte:
		return v * v
	default:
		fmt.Printf("unsupperted data type %T\n", num)
		return nil
	}
}

func square2(num interface{}) interface{} {
	switch num.(type) {
	case int:
		v := num.(int) //类型断言，针对空接口并且在switch中使用
		return v * v
	case float32:
		v := num.(int)
		return v * v
	case float64:
		v := num.(int)
		return v * v
	case byte:
		v := num.(int)
		return v * v
	default:
		fmt.Printf("unsupperted data type %T\n", num)
		return nil
	}
}

func main() {
	// args := []float64{2, 3, 4, 5, 0}
	// result, err := prod1(args...)
	// if err != nil {
	// 	fmt.Println(err)
	// } else {
	// 	fmt.Printf("result=%f\n", result)
	// }

	// res, err := prod(args...)
	// if err != nil {
	// 	fmt.Println(err)
	// } else {
	// 	fmt.Printf("res=%f\n", res)
	// }

	var i int = 2
	var b byte = 2
	var d float32 = 2
	var s float64 = 2
	var w int32 = 2
	fmt.Println(square(i))
	fmt.Println(square(b))
	fmt.Println(square(d))
	fmt.Println(square(s))
	fmt.Println(square(w))
}
```



## day05

### go面向对象编程



#### 构造函数

```
//main.go 
package main

import "fmt"

type User struct {
	Name string
	Age  int
	Sex  byte
}

// 构造函数，返回结构体实例
func NewUser(name string, age int, sex byte) *User {
	return &User{
		Name: name,
		Age:  age,
		Sex:  sex,
	}
}

func NewDefaultUser() *User {
	return &User{
		Name: "",
		Age:  -1,
		Sex:  3,
	}
}

func main() {
	// u1 := &User{}
	// u2 := NewDefaultUser()
	// fmt.Printf("age=%d sex=%d\n", u1.Age, u1.Sex)
	// fmt.Printf("age=%d sex=%d\n", u2.Age, u2.Sex)

	u3 := GetUserInstance()
	u4 := GetUserInstance()
	u4.Age = 18
	fmt.Printf("u3 age %d\n", u3.Age)
	u5 := GetUserInstance()
	fmt.Printf("u5 age %d\n", u5.Age)
}
-----
//singleton.go
package main

import "sync"

var (
	user     *User
	userOnce sync.Once
	pe       *Peeple
	pOnce    sync.Once
)

type Peeple struct {
}

// 单例模式
func GetUserInstance() *User {
	userOnce.Do(func() { //确保整上go进程之间只被执行一次
		if user == nil {
			user = NewDefaultUser()
		}
	})
	return user
}

// 单例模式2
func GetPeepleInstance() *Peeple {
	userOnce.Do(func() { //确保整上go进程之间只被执行一次
		if pe == nil {
			pe = new(Peeple)
		}
	})
	return pe
}

```



#### 继承和组合

```
package main

import "fmt"

type Plane struct {
	Color string
}

func (Plane) Fly() {
	fmt.Println("plane fly")
}

type Human struct {
}

func (Human) Fly() {
	fmt.Println("human fly")
}

type Bird struct { //组合
	Plane //继承
	Human
}

// func (b Bird) Fly() { //重写
// 	b.Plane.Fly()
// 	fmt.Println("bird fly")
// }

func main() {
	b := Bird{}
	fmt.Println(b.Plane.Color)
	fmt.Println(b.Color)
	b.Plane.Fly()
	b.Human.Fly()
	// b.Fly()

}
```



#### 泛型

```
package main

import "fmt"
//没有泛型之前的解决办法
func add4int (a, b int) int {
	return a + b
}
//没有泛型之前的解决办法
func add4string (a, b string) string {
	return a + b
}
//定义泛型Addable
type Addable interface{
	type int, int8, int16, int32, uint8, uint16, float32, float64, complex128, string
}
//定义泛型Addable相关函数
func add[T Addable](a, b T) T{
	return a + b
}

func main(){
	var a, b int=2, 5
	var c, d string= "China", "People"

	add4int(a, b)
	add4string(c, d)
	fmt.Println(add(a,b))
	fmt.Println(add(c,d))
}
// go1.17泛型还在实验阶段，需要运行如下命令开启
PS D:\share\golang-study\day05\generic> go run -gcflags=-G=3 .\main.go
7
ChinaPeople
```



#### 反射

```
# 反射介绍
什么是反射?
	在运行期间（不是编译期间）探知对象的类型信息和内存结构、更新变量、调用它们的方法
何时使用反射?
	函数的参数类型是interface{}，需要在运行时对原始类型进行判断，针对不同的类型采取不同的处理方式。比如json.Marshal(v interface{})
	在运行时根据某些条件动态决定调用哪个函数，比如根据配置文件执行相应的算子函数
使用反射的例子:
type User struct {
	Name string
	Age int
	Sex byte `json:"gender"`
}
user := User{
	Name: "钱钟书",
	Age: 57,
	Sex: 1,
}
json.Marshal(user)
{"Name":"钱钟书","Age":57,"gender":1}

# 反射的弊端
1. 代码难以阅读，难以维护
2. 编译期间不能发现类型错误，覆盖测试难度很大，有些bug需要到线上运行很长时间才能发现，可能会造成严重用后果
3. 反射性能很差，通常比正常代码慢一到两个数量级。在对性能要求很高，或大量反复调用的代码块里建议不要使用反射

# 反射的基础数据类型

原始类型 <-> 强制类型转换 <-> interface{} -> TypeOf() -> type -> New() -> value(相互转换)
							    	  -> ValueOf() -> value -> type() -> type(相互转换)
												   -> Interface() -> interface{}(相互转换)
type Type interface {
	Method(int) Method  //第i个方法
	MethodByName(string) (Method, bool) //根据名称获取方法
	NumMethod() int  //方法的个数
	Name() string   //获取结构体名称
	PkgPath() string //包路径
	Size() uintptr  //占用内存的大小
	String() string  //获取字符串表述
	Kind() Kind  //数据类型
	Implements(u Type) bool  //判断是否实现了某接口
	AssignableTo(u Type) bool  //能否赋给另外一种类型
	ConvertibleTo(u Type) bool  //能否转换为另外一种类型
	Elem() Type  //解析指针
	Field(i int) StructField  //第i个成员
	FieldByIndex(index []int) StructField  //根据index路径获取嵌套成员
	FieldByName(name string) (StructField, bool)  //根据名称获取成员
	FieldByNameFunc(match func(string) bool) (StructField, bool)  //
	Len() int  //容器的长度
	NumIn() int  //输出参数的个数
	NumOut() int  //返回参数的个数
}
获取类型相关的信息	reflect.Type

reflect.Value
type Value struct {
	// 代表的数据类型
	typ *rtype
	// 指向原始数据的指针
	ptr unsafe.Pointer
}
通过reflect.Value可以获取、修改原始数据类型里的值
```



#### 反射API

```
# 获取Type类型
//通过TypeOf()得到Type类型
typeUser := reflect.TypeOf(&common.User{}) 
fmt.Println(typeUser)                     //*common.User
fmt.Println(typeUser.Elem())       //common.User，Elem()对指针类型进行解析
fmt.Println(typeUser.Kind())                 //ptr
fmt.Println(typeUser.Elem().Kind())    //struct

# 获取Field信息
typeUser := reflect.TypeOf(common.User{})
for i := 0; i < typeUser.NumField() ; i++ {//成员变量的个数
field := typeUser.Field(i)
fmt.Printf("%s offset %d anonymous %t type %s exported %t json tag %s\n", 
field.Name, //变量名称
field.Offset, //相对于结构体首地址的内存偏移量，string类型会占据16个字节
field.Anonymous, //是否为匿名成员
field.Type, //数据类型，reflect.Type类型
field.IsExported(), //包外是否可见（即是否以大写字母开头）
field.Tag.Get("json")) //获取成员变量后面``里面定义的tag
}

# 获取method信息
typeUser := reflect.TypeOf(common.User{})
methodNum := typeUser.NumMethod() //成员方法的个数。接收值为指针的方法不包含在内
for i := 0; i < methodNum; i++ {
	method := typeUser.Method(i)
	fmt.Printf("method name:%s ,type:%s, exported:%t\n", 	method.Name, method.Type, method.IsExported())
}

# 获取函数信息
typeFunc := reflect.TypeOf(Add) //获取函数类型
argInNum := typeFunc.NumIn() //输入参数的个数
for i := 0; i < argInNum; i++ {
	argTyp := typeFunc.In(i)
	fmt.Printf("第%d个输入参数的类型%s\n", i, argTyp)
}

# 赋值和转换关系
type1.AssignableTo(type2)  //type1代表的类型是否可以赋值给type2代表的类型
type1.ConvertibleTo(type2) //type1代表的类型是否可以转换成type2代表的类型
java的反射可以获取继承关系，而go语言不支持继承，所以必须是相同的类型才能AssignableTo和ConvertibleTo

# 是否实现接口
typeOfPeople := reflect.TypeOf((*common.People)(nil)).Elem()  //通过reflect.TypeOf((*<interface>)(nil)).Elem()获得接口类型
userType := reflect.TypeOf(&common.User{})
userType.Implements(typeOfPeople)//判断User的指针类型是否实现了People接口
User的值类型实现了接口，则指针类型也实现了接口；但反过来不行

# reflect.Value
userValue := reflect.ValueOf(common.User{
	Id: 7,
	Name: "杰克逊",
	Weight: 65,
	Height: 1.68,
})
user := userValue.Interface().(common.User)//通过Interface()函数把Value转为interface{}，再从interface{}强制类型转换，转为原始数据类型

# 空Value
var i interface{} //接口没有指向具体的值
v := reflect.ValueOf(i)
fmt.Printf("v持有值 %t\n", v.IsValid())
var user *common.User = nil
v = reflect.ValueOf(user) //Value指向一个nil
fmt.Printf("v持有的值是nil %t\n", v.IsNil())
var u common.User //只声明，里面的值都是默认值
v = reflect.ValueOf(u)
fmt.Printf("v持有的值是对应类型的默认值 %t\n", v.IsZero())

# nil
// nil is a predeclared identifier representing the zero value for a // pointer, channel, func, interface, map, or slice type.
var nil Type // Type must be a pointer, channel, func, interface, map, or slice type
应用举例：
var s []int;  s==nil
var err error; err==nil
var foo func(int)string; foo==nil

# Value转为Type
userType := userValue.Type()
userType.Kind() == userValue.Kind() == reflect.Struct


# 代表指针的Value
userPtrValue := reflect.ValueOf(&common.User{})
userValue := userPtrValue.Elem() 
userPtrValue = userValue.Addr() 
user := userValue.Interface().(common.User)
userPtr := userPtrValue.Interface().(*common.User)

# 通过反射修改struct
var s string = "hello"
valueS := reflect.ValueOf(&s)  //必须传指针才能修改数据
valueS.Elem().SetString("golang")  //需要先调Elem()把指针Value转为非指针Value
user := common.User{}
valueUser := reflect.ValueOf(&user)
addrValue := valueUser.Elem().FieldByName("addr")
if addrValue.CanSet() {
	addrValue.SetString("北京")	//未导出成员的值不能修改
}

# 通过反射修改slice
users := make([]*common.User, 1, 5)
users[0] = &common.User{Id: 7}
sliceValue := reflect.ValueOf(&users) //准备通过Value修改users，所以传指针
sliceValue.Elem().Index(0).Elem().FieldByName("Name").SetString("令狐冲")

sliceValue.Elem().SetLen(2)
//调用reflect.Value的Set()函数修改其底层指向的原始数据
sliceValue.Elem().Index(1).Set(reflect.ValueOf(&common.User{Id: 8,Name: "李达"}))


# 通过反射修改map
u1 := &common.User{Id: 7,Name: "杰克逊",}
u2 := &common.User{Id: 8,Name: "杰克逊",}
userMap := make(map[int]*common.User, 5)
userMap[u1.Id] = u1
mapValue := reflect.ValueOf(&userMap)     //注意传指针
mapValue.Elem().SetMapIndex(reflect.ValueOf(u2.Id), reflect.ValueOf(u2))   //SetMapIndex 往map里添加一个key-value对


# 通过反射调用函数
valueFunc := reflect.ValueOf(Add)
args := reflect.Value{reflect.ValueOf(3), reflect.ValueOf(5)}
results := valueFunc.Call(args)   //函数返回是一个列表
sum := results[0].Interface().(int)


# 通过反射调用方法
user := common.User{}
valueUser := reflect.ValueOf(&user) //必须传指针，因为BMI()在定义的时候它是指针的方法
bmiMethod := valueUser.MethodByName("BMI") //MethodByName()通过Name返回类的成员变量
resultValue := bmiMethod.Call([]reflect.Value{}) //无参数时传一个空的切片
result := resultValue[0].Interface().(float32)


# 根据反射创建struct
t := reflect.TypeOf(common.User{})
value := reflect.New(t) //根据reflect.Type创建一个对象，得到该对象的指针，再根据指针提到reflect.Value
value.Elem().FieldByName("Name").SetString("宋江")
user := value.Interface().(*common.User) //把反射类型转成go原始数据类型


# 根据反射创建slice
var slice []common.User
sliceType := reflect.TypeOf(slice)
sliceValue := reflect.MakeSlice(sliceType, 1, 3) sliceValue.Index(0).Set(reflect.ValueOf(common.User{Id: 8}))
users := sliceValue.Interface().([]common.User)


# 根据反射创建map
var userMap map[int]*common.User
mapType := reflect.TypeOf(userMap)
mapValue := reflect.MakeMapWithSize(mapType, 10) 
user := &common.User{Id:7}
key := reflect.ValueOf(user.Id)
mapValue.SetMapIndex(key, reflect.ValueOf(user))//SetMapIndex 往map里添加一个key-value对
userMap = mapValue.Interface().(map[int]*common.User)

```





#### 

## day06



##### go语言包与工程化

1.用go mod管理工程

2.包引入规则

3.init调用链

4.可见性



###### 用go mod管理工程

```
# 创建项目
go mod init $module_name
$module_name和目录名可以不一样

module go-course
go 1.17
require (
	github.com/ethereum/go-ethereum v1.10.8
	github.com/gin-gonic/gin v1.7.4
)


# 包查找规则
依次从当前项目、$GOROOT、$GOPATH下寻找依赖包
1. 从当前go文件所在的目录逐级向上查找go.mod文件（假设go.mod位于目录$mode_path下），里面定义了module_name，则引入包的路径为module_name/包相对于$mode_path的路径
2. go标准库提供的包在$GOROOT/src下
3. 第三方依赖包在$GOPATH/pkg/mod下


# 包管理
1. 从go1.7开始，go get只负责下载第三方依赖包，并把它加到go.mod文件里，由go install负责安装二进制文件
	go get github.com/mailru/easyjson会在$GOPATH/pkg/mod目录下生成github.com/mailru/easyjson目录
	go install github.com/mailru/easyjson/easyjson会在$GOPATH/bin下生成easyjson二进制可执行文件
2. go mod tidy通过扫描当前项目中的所有代码来添加未被记录的依赖至go.mod文件或从go.mod文件中删除不再被使用的依赖

```



###### 包引入规则

```
# 包的声明
* go文件的第一行声明 package xxx
* 在包声明的上面可写关于包的注释，包注释也可以专门写在doc.go里
* 包名跟目录名可以不同
* 同一个目录下，所有go文件的包名必须一致

# 包的引用
* 可以直接使用同目录下其他go文件里的变量、函数、结构体
* 跨目录使用则需要变量前加入包名，并且引入包所在的目录
imoprt "go-course/package"
mypackage.Add()
mypackage是包名(Add函数所有go文件的package名称)，它所在的目录是go-course/package

* 在import块里可以引用父目录，也可以引用子目录
* 引用关系不能构成一个环
* 在import的目录前面可以给包起一个别名
imoprt asd "go-course/package"
asd.Add()

```



###### init调用链

```
# init()函数
* main函数是go程序的唯一入口，所以main函数只能存在一个
* main函数必须位于main包中
* 在main函数执行之前会先执行init()函数
* 在一个目录，甚至一个go文件里，init()可以重复定义
* 引入其他包时，相应包里的init()函数也会在main()函数之前被调用
* init函数调用优先级：import包的顺序执行 -> 依赖包中依赖其它包时，最后被依赖的init()优先被执行

```



###### 可见性

```
# 可见性
* 以小写字母开头命名的函数、变量、结构体只能在本包内访问
* 以大写字母开头命名的函数、变量、结构体在其他包中也可以访问
* 如果结构体名字以大写字母开头，而其成员变量、成员方法以小写字母开头，则这样的成员只能在本包内访问


# internal包
* Go中命名为internal的package，只有该package的上一级package才可以访问该package的内容
* （internal的上一级目录）及其子孙目录之间可以任意import，但a目录和b目录不能import internal及其下属的所有目录
目录结构：a -> b -> c -> d
					-> internel -> e -> f -> e.go
										  -> f.go
										  -> x.go
```



##### go语言常用标准库

##### 数学计算

```
# 数学常量
math.E	//自然对数的底，2.718281828459045
math.Pi	//圆周率，3.141592653589793
math.Phi	//黄金分割，长/短，1.618033988749895
math.MaxInt	//9223372036854775807
uint64(math.MaxUint)	//得先把MaxUint转成uint64才能输出，18446744073709551615
math.MaxFloat64	//1.7976931348623157e+308
math.SmallestNonzeroFloat64	//最小的非0且正的浮点数，5e-324


# NaN
Not a Number
f := math.NaN()
math.IsNaN(f)


# 常用函数
math.Ceil(1.1)	//向上取整，2
math.Floor(1.9)	//向下取整，1。 math.Floor(-1.9)=-2
math.Trunc(1.9)	//取整数部分，1
math.Modf(2.5)	//返回整数部分和小数部分，2  0.5
math.Abs(-2.6)	//绝对值，2.6
math.Max(4, 8)	//取二者的较大者，8
math.Min(4, 8)	//取二者的较小者，4
math.Mod(6.5, 3.5)	//x-Trunc(x/y)*y结果的正负号和x相同，3
math.Sqrt(9)		//开平方，3
math.Cbrt(9)		//开三次方，2.08008


# 三角函数
math.Sin(1)
math.Cos(1)
math.Tan(1)
math.Tanh(1)


# 对数和指数
math.Log(5)	//自然对数，1.60943
math.Log1p(4)	//等价于Log(1+p)，确保结果为正数，1.60943
math.Log10(100)	//以10为底数，取对数，2
math.Log2(8)	//以2为底数，取对数，3
math.Pow(3, 2)	//x^y，9
math.Pow10(2)	//10^x，100
math.Exp(2)	//e^x，7.389


# 随机数生成器
rand.Seed(1) //如果对两次运行没有一致性要求，可以不设seed
fmt.Println(rand.Int()) //随机生成一个整数
fmt.Println(rand.Float32()) //随机生成一个浮点数
fmt.Println(rand.Intn(100)) //100以内的随机整数，[0,100)
arr := rand.Perm(100) //把[0,100)上的整数随机打乱
rand.Shuffle(len(arr), func(i, j int) { //随机打乱一个给定的slice
	arr[i], arr[j] = arr[j], arr[i]
})


# gonum
gonum是用纯go语言(带一些汇编)开发的数值算法库，包含统计、矩阵、数值优化
第三方库go get gonum.org/v1/gonum
arr,brr := []float64{1, 2, 3, 4, 5}, []float64{6, 7, 8, 9, 10}
fmt.Println(stat.Mean(arr, nil)) //均值
fmt.Println(stat.Variance(arr, nil)) //方差
fmt.Println(stat.Covariance(arr, brr, nil)) //协方差
fmt.Println(stat.CrossEntropy(arr, brr)) //交叉熵

```



##### 时间函数

```
# 解析和格式化
TIME_FMT := "2006-01-02 15:04:05"
now := time.Now()
ts := now.Format(TIME_FMT)
loc, _ = time.LoadLocation("Asia/Shanghai")
t, _ = time.ParseInLocation(TIME_FMT, ts, loc)


# 时间运算
diff1 := t1.Sub(t0) //计算t1跟t0的时间差，返回类型是time.Duration
diff2 := time.Since(t0) //计算当前时间跟t0的时间差，返回类型是time.Duration
diff3 := time.Duration(3 * time.Hour) //Duration表示两个时刻之间的距离
t4 := t0.Add(diff3) 
t4.After(t0)    //true


# 时间的属性
t0.Unix(), t0.UnixMilli(), t0.UnixMicro(), t0.UnixNano()
t2.Year(), t2.Month(), t2.Day(), t2.YearDay()
t2.Weekday().String(), t2.Weekday()
t1.Hour(), t1.Minute(), t1.Second()


# 定时执行
tm := time.NewTimer(3 * time.Second)
<-tm.C //阻塞3秒钟
//do something
tm.Stop()
或者用：
<-time.After(3 * time.Second) //阻塞3秒钟


# 周期执行
tk := time.NewTicker(1 * time.Second)
for i := 0; i < 10; i++ {
<-tk.C //阻塞1秒钟
//do something
}
tk.Stop()
```





##### I/O操作

```
# 标准输入
fmt.Println("please input two word")
var word1 string 
var word2 string
fmt.Scan(&word1, &word2) //读入多个单词，空格分隔。如果输入了更多单词会被缓存起来，丢给下一次scan
fmt.Println("please input an int")
var i int
fmt.Scanf("%d", &i) //类似于Scan，转为特定格式的数据


# 打开文件
func os.Open(name string) (*os.File, error)
fout, err := os.OpenFile("data/verse.txt", os.O_CREATE|os.O_TRUNC|os.O_WRONLY, 0666)
os.O_WRONLY以只写的方式打开文件，os.O_TRUNC把文件之前的内容先清空掉，os.O_CREATE如果文件不存在则先创建，0666新建文件的权限设置


# 读文件
reader := bufio.NewReader(fin) //读文件文件建议用bufio.Reader
for { //无限循环
if line, err := reader.ReadString('\n'); err != nil { //指定分隔符
if err == io.EOF {
	break //已读到文件末尾
} else {
	fmt.Printf("read file failed: %v\n", err)
}
} else {
	line = strings.TrimRight(line, "\n") //line里面是包含换行符的，需要去掉
	fmt.Println(line)
}
}

# 写文件
defer fout.Close() //别忘了关闭文件句柄
writer := bufio.NewWriter(fout)
writer.WriteString("明月多情应笑我")
writer.WriteString("\n") //需要手动写入换行符


# 创建文件/目录
os.Create(name string)//创建文件
os.Mkdir(name string, perm fs.FileMode)//创建目录
os.MkdirAll(path string, perm fs.FileMode)//增强版Mkdir，沿途的目录不存在时会一并创建
os.Rename(oldpath string, newpath string)//给文件或目录重命名，还可以实现move的功能
os.Remove(name string)//删除文件或目录，目录不为空时才能删除成功
os.RemoveAll(path string)//增强版Remove，所有子目录会递归删除


# 遍历目录
if fileInfos, err := ioutil.ReadDir(path); err != nil {
	return err
} else {
for _, fileInfo := range fileInfos {
fmt.Println(fileInfo.Name())
if fileInfo.IsDir() { //如果是目录，就递归子遍历
	walk(filepath.Join(path, fileInfo.Name}
}
}


# 日志
默认的log输出到控制台
log.Printf("%d+%d=%d\n", 3, 4, 3+4)
log.Println("Hello Golang")
log.Fatalln("Bye, the world") //日志输出后会执行os.Exit(1)
指定日志输出到文件
logWriter := log.New(fout, "[BIZ_PREFIX]", log.Ldate|log.Lmicroseconds) //通过flag参数定义日志的格式
logWriter.Println("Hello Golang")


# 调用系统命令
cmd_path, err := exec.LookPath(“df”) //查看系统命令所在的目录，确保命令已安装
cmd := exec.Command("df", "-h") //相当于命令df -h，注意Command的每一个参数都不能包含空格
output, err := cmd.Output() //cmd.Output()运行命令并获得其输出结果
cmd = exec.Command("rm", "./data/test.log")
cmd.Run() //如果不需要获得命令的输出，直接调用cmd.Run()即可

```





##### 编码

```
# json
json是go标准库里自带的序列化工具，使用了反射，效率比较低
easyjson只针对预先定义好的json结构体对输入的json字符串进行纯字符串的截取，并将对应的json字段赋值给结构体
easyjson -all xxx.go 生成go文件中定义的结构体对应的解析
func easyjson.Marshal(v easyjson.Marshaler) ([]byte, error)
func easyjson.Unmarshal(data []byte, v easyjson.Unmarshaler) error


# base64
任意byte数组都可以采用base64编码转为字符串，并且可以反解回byte数组
编码和解码的方法是公开、确定的， base64不属于加密算法
base64经常在http环境下用来传输较长的信息
func (*base64.Encoding).EncodeToString(src []byte) string
func (*base64.Encoding).DecodeString(s string) ([]byte, error)


# 压缩和解压
compress包下实现了zlib、bzip、gip、lzw等压缩算法
writer := zlib.NewWriter(fout)//压缩
writer.Write(bytes)
reader, err := zlib.NewReader(fin) //解压
io.Copy(os.Stdout, reader) 

```









## day07

##### go重点基础知识回顾

##### 特征抽取

##### 单元测试、基准测试

```
# 单元测试
func TestStrCat(b *testing.T) {
	hello := "hello"
	golang := "golang"
	fmt.Printf("%s %s\n", hello, golang)
}

go test -v go_test.go -timeout=20m -count=1
-v 打印详情测试信息
-timeout 默认10分钟超时
-count 函数运行几次


# 基准测试
func BenchmarkStrCat(b *testing.B) {
    hello := "hello"
    golang := "golang"
    for i := 0; i < b.N; i++ {
        fmt.Printf("%s %s\n", 	hello, golang)
    }
}

go test -bench=StrCat -run=^$ -benchmem -benchtime=2s -cpuprofile=data/cpu.prof -memprofile=data/mem.prof
-bench 正则指定运行哪些基准测试
-run 正则指定运行哪些单元测试
-benchmem 输出内存分配情况
-benchtime 每个函数运行多长时间


# 测试代码规范
单元测试和基准测试必须放在以_test.go为后缀的文件里。
单元测试函数以Test开头，基准测试函数以Benchmark开头。
单元测试以*testing.T为参数，函数无返回值。
基准测试以*testing.B为参数，函数无返回值。


# pprof
proof是可视化性能分析工具，提供以下功能：
CPU Profiling：按一定频率采集CPU使用情况
Memory Profiling：监控内存使用情况，检查内存泄漏
Goroutine Profiling：对正在运行的Goroutine进行堆栈跟踪和分析，检查协程泄漏


# cpu监控
go tool pprof data/cpu.prof
常用命令：topn, list func, peek func, web


# pprof web可视化
go tool pprof -http=:8080 data/cpu.prof


```







## day08*

##### 常用加解密算法

1.对称加密

2.非对称加密

3.哈希算法



###### 对称加密(双向加密算法)

```
加密过程的每一步都是可逆的
加密和解密用的是同一组密钥
异或是最简单的对称加密算法

# DES数组分级
DES（Data Encryption Standard）数据加密标准，是目前最为流行的加密算法之一
对原始数据（明文）进行分组，每组64位，最后一组不足64位时按一定规则填充
每一组上单独施加DES算法

# DES子密钥生成
初始密钥64位，实际有效位56位，每隔7位有一个校验位
根据初始密钥生成16个48位的子密钥

# AES
AES（Advanced Encryption Standard）高级加密标准，旨在取代DES

```



###### 非对称加密(双向加密算法)

```
使用公钥加密，使用私钥解密
公钥和私钥不同
公钥可以公布给所有人
私钥只有自己保存
相比于对称加密，运算速度非常慢

# 对称加密和非对称加密结合使用
小明要给小红传输机密文件，他俩先交换各自的公钥，然后：
小明生成一个随机的AES口令，然后用小红的公钥通过RSA加密这个口令，并发给小红
小红用自己的RSA私钥解密得到AES口令
双方使用这个共享的AES口令用AES加密通信

# RSA
Ron Rivest，Adi Shamir，Leonard Adleman
密钥越长，越难破解。 目前768位的密钥还无法破解（至少没人公开宣布）。因此可以认为1024位的RSA密钥基本安全，2048位的密钥极其安全
RSA的算法原理主要用到了数论

# RSA加密过程
随机选择两个不相等的质数p和q。p=61, q=53
计算p和q的乘积n。n=3233
计算n的欧拉函数φ(n) = (p-1)(q-1)。 φ(n) =3120
随机选择一个整数e，使得1< e < φ(n)，且e与φ(n) 互质。e=17
计算e对于φ(n)的模反元素d，即求解e*d+ φ(n)*y=1。d=2753, y=-15
将n和e封装成公钥，n和d封装成私钥。公钥=(3233，17)，公钥=(3233，2753)



# 椭圆曲线加密
ECC（Elliptic Curve Cryptography）椭圆曲线加密算法，相比RSA，ECC可以使用更短的密钥，来实现与RSA相当或更高的安全
定义了椭圆曲线上的加法和二倍运算
椭圆曲线依赖的数学难题是：k为正整数，P是椭圆曲线上的点（称为基点）, k*P=Q , 已知Q和P，很难计算出k

```



###### 哈希算法(单向加密算法)

```
# 哈希函数的基本特征
输入可以是任意长度
输出是固定长度
根据输入很容易计算出输出
根据输出很难计算出输入（几乎不可能）
两个不同的输入几乎不可能得到相同的输出
特点：单向性、唯一性

# sha1
SHA（Secure Hash Algorithm） 安全散列算法，是一系列密码散列函数，有多个不同安全等级的版本：SHA-1,SHA-224,SHA-256,SHA-384,SHA-512
防伪装，防窜扰，保证信息的合法性和完整性
填充。使得数据长度对512求余的结果为448
在信息摘要后面附加64bit，表示原始信息摘要的长度
初始化h0到h4，每个h都是32位
h0到h4历经80轮复杂的变换
把h0到h4拼接起来，构成160位，返回


# md5
MD5（Message-Digest Algorithm 5）信息-摘要算法5，算法流程跟SHA-1大体相似
MD5的输出是128位，比SHA-1短了32位
MD5相对易受密码分析的攻击，运算速度比SHA-1快



# 哈希函数的应用
用户密码的存储
文件上传/下载完整性校验
mysql大字段的快速对比


#数字签名
RSA+哈希函数
```





##### 数据结构与算法

1.链表

2.栈

3.堆

4.Trie树



###### 链表

```
# 链表
1. 单向链表
2. 双向链表,go语言只实现了双向链表，功能包含单向链表，container/list是双向链表

# 链表的应用：LRU缓存淘汰
LRU(Least Recently Used)最近最少使用
思路：缓存的key放到链表中，头部的元素表示最近刚使用
如果命中缓存，从链表中找到对应的key，移到链表头部
如果没命中缓存：
如果缓存容量没超，放入缓存，并把key放到链表头部
如果超出缓存容量，删除链表尾部元素，再把key放到链表头部


# 循环链表
双向循环链表，container/ring是双向循环链表

# ring的应用：基于滑动窗口的统计
最近100次接口调用的平均耗时、最近10笔订单的平均值、最近30个交易日股票的最高点
ring的容量即为滑动窗口的大小，把待观察变量按时间顺序不停地写入ring即可

```



###### 栈

先进后出



###### 栈

```
堆是一棵二叉树
大根堆：任意节点的值都大于等于其子节点。反之为小根堆

# 堆的应用
堆排序
1. 构建堆O(N)
2. 不断地删除堆顶O(NlogN)
求集合中最大的K个元素
1. 用集合的前K个元素构建小根堆
2. 逐一遍历集合的其他元素，如果比堆顶小直接丢弃；否则替换掉堆顶，然后向下调整堆
把超时的元素从缓存中删除
1. 按key的到期时间把key插入小根堆中
2. 周期扫描堆顶元素，如果它的到期时间早于当前时刻，则从堆和缓存中删除，然后向下调整堆


# 堆的实现
golang中的container/heap实现了小根堆，但需要自己定义一个类，实现以下接口：
Len() int, Less(i, j int) bool, Swap(i, j int)
Push(x interface{})
Pop() x interface{}


```





###### trie树

```
根节点是总入口，不存储字符
对于英文，第个节点有26个子节点，子节点可以存到数组里；中文由于汉字很多，用数组存子节点太浪费内存，可以用map存子节点。
从根节点到叶节点的完整路径是一个term
从根节点到某个中间节点也可能是一个term，即一个term可能是另一个term的前缀

```







## day09

##### go语言并发编程

1.并发编程模型

2.Goroutine的使用

3.Channel的同步与异步



###### 并发编程模型



进程与线程

```
任何语言的并行，到操作系统层面，都是内核线程的并行。
同一个进程内的多个线程共享系统资源，进程的创建、销毁、切换比线程大很多。
从进程到线程再到协程, 其实是一个不断共享, 不断减少切换成本的过程。
```

协程 VS 线程

|          | 协程                                       | 线程                                            |
| -------- | ------------------------------------------ | ----------------------------------------------- |
| 创建数量 | 轻松创建上百万个协程而不会导致系统资源衰竭 | 通常最多不能超过1万个                           |
| 内存占用 | 初始分配4k堆栈，随着程序的执行自动增长删除 | 创建线程时必须指定堆栈且是固定的，通常以M为单位 |

|          | 协程                                                         | 线程                                                         |
| -------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 切换成本 | 协程切换只需保存三个寄存器，耗时约200纳秒                    | 线程切换需要保存几十个寄存器，耗时约1000纳秒                 |
| 调度方式 | 非抢占式，由Go runtime主动交出控制权（对于开发者而言是抢占式） | 在时间片用完后，由 CPU 中断任务强行将其调度走，这时必须保存很多信息 |

|          | 协程                                                         | 线程                                                         |
| -------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 创建销毁 | goroutine因为是由Go runtime负责管理的，创建和销毁的消耗非常小，是用户级的 | 创建和销毁开销巨大，因为要和操作系统打交道，是内核级的，通常解决的办法就是线程池 |

```
# 查看逻辑核心数
fmt.Println(runtime.NumCPU())


# MPG并发模型
M(Machine)对应一个内核线程。
P(Processor)虚拟处理器，代表M所需的上下文环境，是处理用户级代码逻辑的处理器。P的数量由环境变量中的GOMAXPROCS决定，默认情况下就是核数。
G(Goroutine)本质上是轻量级的线程，G0正在执行，其他G在等待。
M和内核线程的对应关系是确定的。
G0阻塞(如系统调用)时，P与G0、M0解绑，P被挂到其他M上，然后继续执行G队列。
G0解除阻塞后，如果有空闲的P，就绑定M0并执行G0；否则G0进入全局可运行队列(runqueue)。P会周期性扫描全局runqueue，使上面的G得到执行；如果全局runqueue为空，就从其他P的等待队列里偷一半G过来。

```



###### Goroutine的使用

```
func Add(a, b int) int {
	fmt.Println("Add")
	return a + b
}
go Add(2, 4)


go func(a, b int) int {
	fmt.Println("add")
	return a + b
}(2, 4)


# 优雅地等子协程结束
wg := sync.WaitGroup{}
wg.Add(10) //加10
for i := 0; i < 10; i++ {
	go func(a, b int) { //开N个子协程
		defer wg.Done() //减1
		//do something
	}(i, i+1)
}
wg.Wait() //等待减为0
注：
父协程结束后，子协程并不会结束
main协程结束后，所有协程都会结束
当main协程阻塞后并且无其它协程时、或者当多个协程都阻塞时,程序将会退出报fatal error:deadlock。
协程并发使用时，list、slice、struct可以直接修改，但map不能直接修改（会报fatal error），可以使用sync.Map实现
var mp sync.Map	//声明线程安全的map
mp.Store(1, true)	//插入Key、value
mp.Range(func(key, value interface{}) bool {	//调用range方法传入回调函数，打印key、value
		fmt.Println(key, value)
		return true
	})


# 闭包
arr := []int{1, 2, 3, 4}
for _, v := range arr {
	go func(value int) {
		fmt.Printf("%d\t", value)//1 4 2 3
	}(v) //把v的副本传到协程内部
}


# sync.Once
确保在高并发的场景下有些事情只执行一次，比如加载配置文件、关闭管道等
var resource map[string]string
var loadResourceOnce sync.Oncefunc LoadResource() {
	loadResourceOnce.Do(func() {
		resource["1"] = "A"
	})
}
或
type Singleton struct {}var singleton *Singleton
var singletonOnce sync.Oncefunc GetSingletonInstance() *Singleton {
	singletonOnce.Do(func() {
		singleton = &Singleton{}
	})
	return singleton
}


# 捕获子协程的panic
何时会发生panic:
	运行时错误会导致panic，比如数组越界、除0
	程序主动调用panic(error)
panic会执行什么：
	逆序执行当前goroutine的defer链（recover从这里介入）
	打印错误信息和调用堆栈
	调用exit(2)结束整个进程


# defer
defer在函数退出前被调用，注意不是在代码的return语句之前执行，因为return语句不是原子操作
如果发生panic，则之后注册的defer不会执行
defer服从先进后出原则，即一个函数里如果注册了多个defer，则按注册的逆序执行
defer后面可以跟一个匿名函数


# recover
recover会阻断panic的执行
func soo(a, b int) {
	defer func() {
		//recover必须在defer中才能生效
		if err := recover(); err != nil {			fmt.Printf("soo函数中发生了panic:%s\n", err)
		}
	}()
	panic(errors.New("my error"))
}

```



###### Channel的同步与异步

```
# 共享内存(全局变量)
多线程共享内存来进行通信
通过加锁来访问共享数据，如数组、map或结构体
go语言也实现了这种并发模型


# CSP
CSP即communicating sequential processes，在go语言里就是Channel
CSP讲究的是“以通信的方式来共享内存”


# 同步channel
创建同步管道		syncChann := make(chan int)
往管道里放数据	syncChann <- 1		生产者
从管道取出数据	v := <- syncChann	消费者


# channel的死锁问题
Channel满了，就阻塞写；Channel空了，就阻塞读
阻塞之后会交出cpu，去执行其他协程，希望其他协程能帮自己解除阻塞
如果阻塞发生在main协程里，并且没有其他子协程可以执行，那就可以确定“希望永远等不来”，自已把自己杀掉，报一个fatal error:deadlock出来
如果阻塞发生在子协程里，就不会发生死锁，因为至少main协程是一个值得等待的“希望”，会一直等（阻塞）下去


# 异步channel
channel底层维护一个环形队列，make时指定队列的长度，ch:=make(chan int,8) 
队列满时，写阻塞；队列空时，读阻塞


# chan struct{}
channel仅作为协程间同步的工具，不需要传递具体的数据，管道类型可以用struct{}
sc := make(chan struct{})
sc <- struct{}{}
空结构体变量的内存占用为0，因此struct{}类型的管道比bool类型的管道还要省内存


# 关闭channel
只有当管道关闭时，才能通过range遍历管道里的数据，否则会发生fatal error
管道关闭后读操作会立即返回，如果缓冲已空会返回“0值”
ele, ok := <-ch  	ok==true代表ele是管道里的真实数据
向已关闭的管道里send数据会发生panic
不能重复关闭管道，不能关闭值为nil的管道，否则都会panic


# 数据传输
管道充当缓冲池，削锋填谷，在处理慢的地方多开几个协程

# 广播
# 协调同步
```







##### go语言并发改进

1.并发安全

2.多路复用

3.协程泄漏

4.协程管理



###### 并发安全

```
# 资源竞争
多协程并发修改同一块内存，产生资源竞争
go run或go build时添加-race参数检查资源竞争情况
n++不是原子操作，并发执行时会存在脏写。n++分为3步：取出n，加1，结果赋给n。测试时需要开1000个并发协程才能观察到脏写
a=n
b=a+1
n=b


# 原子操作
func atomic.AddInt32(addr *int32, delta int32) (new int32)
func atomic.LoadInt32(addr *int32) (val int32)
把n++封装成原子操作，解除资源竞争，避免脏写


# 读写锁
var lock sync.RWMutex		声明读写锁，无需初始化
lock.Lock() lock.Unlock()	加写锁和释放写锁
lock.RLock() lock.RUnlock()	加读锁和释放读锁
任意时刻只可以加一把写锁，且不能加读锁
没加写锁时，可以同时加多把读锁，读锁加上之后不能再加写锁


# 容器的并发安全性
数组、slice、struct允许并发修改（可能会脏写），并发修改map有时会发生panic
如果需要并发修改map请使用sync.Map
```



###### 多路复用

```
# I/O模型
操作系统级的I/O模型有：
阻塞I/O
非阻塞I/O
信号驱动I/O
异步I/O
多路复用I/O


# 文件描述符
Linux下，一切皆文件。包括普通文件、目录文件、字符设备文件（键盘、鼠标）、块设备文件（硬盘、光驱）、套接字socket等等
文件描述符（File descriptor，FD）是访问文件资源的抽象句柄，读写文件都要通过它
文件描述符就是个非负整数，每个进程默认都会打开3个文件描述符：0标准输入、1标准输出、2标准错误
由于内存限制，文件描述符是有上限的，可通过ulimit –n查看，文件描述符用完后应及时关闭


# 阻塞I/O
1. 执行系统调用，由用户态陷入内核态
2. 文件描述符中还没有数据，阻塞
3. 已有数据，操作系统将数据拷贝给应用程序
4. 退出系统调用，交回控制权


# 非阻塞I/O
立即返回EAGAIN(一个负数)错误，表示文件描述符还在等待缓冲区中的数据
不断轮询，期间可以执行其它任务，提高CPU利用率
read和write默认是阻塞模式
	ssize_t read(int fd, void *buf, size_t count); 
	ssize_t write(int fd, const void *buf, size_t nbytes);
通过系统调用fcntl可将文件描述符设置成非阻塞模式
	int flags = fcntl(fd, F_GETFL, 0); 
	fcntl(fd, F_SETFL, flags | O_NONBLOCK);


# 多路复用I/O
select系统调用可同时监听1024个文件描述符的可读或可写状态
poll用链表存储文件描述符，摆脱了1024的上限
各操作系统实现了自己的I/O多路复用函数，如epoll、 evport 和kqueue 等
步骤：
1. 所有读写fd都没准备好
2. 部分fd准备就绪，select返回可读或可写的事件个数
3. 以O(N)遍历所有fd，对就绪的fd进行读写


# go多路复用
go多路复用函数以netpoll为前缀，针对不同的操作系统做了不同的封装，以达到最优的性能
在编译go语言时会根据目标平台选择特定的分支进行编译


# go channel多路复用
select { //同时监听3个channel，哪个最先被case匹配到的将会执行并且退出select，如果外部是for循环将一直监听
case n := <-countCh:
	fmt.Println(n)
case <-finishCh:
	fmt.Println("finish")
case <-abortCh:
	fmt.Println("abort")
}


# timeout实现
ctx, cancel := context.WithCancel(context.Background())
调用cancel()将关闭ctx.Done()对应的管道
ctx, cancel := context.WithTimeout(context.Background (),time.Microsecond*100)
调用cancel()或到达超时时间都将关闭ctx.Done()对应的管道
ctx.Done()管道关闭后读操作将立即返回

```



###### 协程泄漏

```
# 协程泄漏的原因
协程阻塞，未能如期结束
协程阻塞最常见的原因都跟channel有关
由于每个协程都要占用内存，所以协程泄漏也会导致内存泄漏


# 协程泄漏的排查
import (
	"net/http"
	_ "net/http/pprof"
)
func main() {
go func() {
	if err := http.ListenAndServe("localhost:8080", nil); err != nil {
		panic(err)
	}
}()
}
步骤：
先把程序run起来
1. 在浏览器访问127.0.0.1:8080/debug/pprof/goroutine?debug=1
2. 在终端执行 go tool pprof http://0.0.0.0:8080/debug/pprof/goroutine
通过list查看函数每行代码产生了多少协程，例如：list main.handle.func1
3. 通过traces打印调用堆栈，main.handle.func1由于调用了chansend1而阻塞了1132个协程
在pprof中输入web命令，相当于是traces命令的可视化
4. 终端执行 go tool pprof --http=:8081 /Users/zhangchaoyang/pprof/pprof.goroutine.001.pb.gz 
在source view下可看到哪行代码生成的协程最多
```



###### 协程管理

```
# goroutine的管理
runtime.GOMAXPROCS(2)	分配2个逻辑处理器给调度器使用
runtime.Gosched()	当前goroutine从当前线程退出，并放回到队列
runtime.NumGoroutine()	查看当前存在的协程数
通过带缓冲的channel可以实现对goroutine数量的控制


# 优雅地退出守护协程
守护协程：独立于控制终端和用户请求的协程，它一直存在，周期性执行某种任务或等待处理某些发生的事件。伴随着main协程的退出，守护协程也退出。
kill命令不是杀死进程，它只是向进程发送信号kill –s pid，s的默认值是15。常见的终止信号如下：
信号	值	说明
SIGINT	2	Ctrl+C触发
SIGKILL	9	无条件结束程序，不能捕获、阻塞或忽略
SIGTERM	15	结束程序，可以捕获、阻塞或忽略
代码：
type Context interface {
	Deadline() (deadline time.Time, ok bool)
	Done() <-chan struct{}
}
func WithCancel(parent Context) (ctx Context, cancel CancelFunc)
当Context的deadline到期或调用了CancelFunc后，Context的Done()管道会关闭，该管道上关联的读操作会解除阻塞，然后执行协程退出前的清理工作。


# 协程管理组件
go get github.com/x-mod/routine
封装了常规的业务逻辑：初始化、收尾清理、工作协程、守护协程、监听term信号
封装了常见的协程组织形式：并行、串行、定时任务、超时控制、重试、profiling

```





## day10

* Go语言Socket编程

1.网络通信过程

2.TCP CS架构实现

3.UDP CS架构实现

---

##### 网络请求过程

•DMA：网卡和磁盘数据拷贝到内存流程比较固定，不涉及到运算操作，且非常耗时。在磁盘嵌入一个DMA芯片，完成上述拷贝工作，把CPU解脱出来，让CPU专注于运算

•mmap：用户空间和内核空间映射同一块内存空间，从而达到省略将数据从内核缓冲区拷贝到用户空间的操作，用户空间通过映射直接操作内核缓冲区的数据



##### 网络进程标识

•用三元给（ip地址，协议，端口号）唯一标示网络中的一个进程，如（172.122.121.111, tcp, 5656）

•IPv4的地址位数为32位，分为4段，每段最大取值为255

•IPv6的地址位数为128位，分为8段，各段用16进制表示，最大取值为ffff

•端口：0~1023被熟知的应用程序占用（普通应用程序不可以使用），49152~65535客户端程序运行时动态选择使用



##### go TCP编程接口

func ResolveTCPAddr(net, addr string) (*TCPAddr, os.Error)

•net参数是“tcp4”、“tcp6”、“tcp”中的任意一个，分别表示TCP（IPv4-only），TCP（IPv6-only）或者TCP（IPv4,、IPv6的任意一个）

•addr表示域名或者IP地址，例如" www.qq.com:80" 或者"127.0.0.1:22"

func DialTCP(network string, laddr, raddr *TCPAddr) (*TCPConn, error)

•network参数是"tcp4"、"tcp6"、"tcp"中的任意一个

•laddr表示本机地址，一般设置为nil

•raddr表示远程的服务地址

func net.DialTimeout(network string, address string, timeout time.Duration) (net.Conn, error)

•创建连接时设置超时时间

func (*net.conn) Write(b []byte) (int, error)

•通过conn发送数据

func (net.Conn).Read(b []byte) (n int, err error)

•从conn里读取数据，如果没有数据可读，会阻塞

func ioutil.ReadAll(r io.Reader) ([]byte, error)

•从conn中读取所有内容，直到遇到error(比如连接关闭)或EOF

func ListenTCP(network string, laddr *TCPAddr) (*TCPListener, error)

•监听端口

func (l *TCPListener) Accept() (Conn, error)

•阻塞，直到有客户端请求建立连接

func (*net.conn) Close() error

•关闭连接

func (c *TCPConn) SetReadDeadline(t time.Time) error func (c *TCPConn) SetWriteDeadline(t time.Time) error

•设置从一个tcp连接上读取和写入的超时时间

func (c *TCPConn) SetKeepAlive(keepalive bool) os.Error

•当一个tcp连接上没有数据时，操作系统会间隔性地发送心跳包，如果长时间没有收到心跳包会认为连接已经断开



##### 连接关闭

•连接关闭后，再调用conn.Write()和conn.Read()会返回fatal error

•如果对方已关闭连接， conn.Write()和conn.Read()是感知不到的，不会返回错误



##### UDP的特征

•不需要建立连接，直接收发数据，效率很高

•面向报文。对应用层交下来的报文，既不合并也不拆分，直接加上边界交给IP层。TCP是面向字节流，TCP有一个缓冲，当应用程序传送的数据块太长，TCP就可以把它划分短一些再传送；如果应用程序一次只发送一个字节，TCP也可以等待积累有足够多的字节后再构成报文段发送出去。

•从机制上不保证顺序（在IP层要对数据分段），可能会丢包（检验和如果出差错就会把这个报文丢弃掉）。在内网环境下分片乱序和数据丢包极少发生

•支持一对一、一对多、多对一和多对多的交互通信

•首部开销小，只占8个字节



* Go语言WebSocket编程

1.TLS协议及配置

2.WebSocket协议解读

3.WebSocket CS架构实现

4.聊天室实现

---

##### TLS协议及配置

###### TLS协议

•很多应用层协议（http、ftp、smtp等）直接使用明文传输

•TLS（Transport Layer Security，安全传输层)将应用层的报文进行加密后再交由TCP进行传输

•TLS 在SSL v3.0 的基础上，提供了一些增强功能，两者差别很小

| 保密性 | 信息加密传输（对称加密）           |
| ------ | ---------------------------------- |
| 完整性 | MAC检验（散列函数）                |
| 认证   | 双方都可以配备证书，防止身份被冒充 |



###### TLS的核心原理

小明要给小红传输机密文件，他俩先交换各自的公钥，然后：

1.小明生成一个随机的AES口令，然后用小红的公钥通过RSA加密这个口令，并发给小红

2.小红用自己的RSA私钥解密得到AES口令

3.双方使用这个共享的AES口令加密通信



###### TLS证书

证书(certificate, 缩写CRT) ，其实就是非对称加密中的公钥，加上一些别的信息组成的一个文件。

TLS 通过两个证书来实现服务端身份验证，以及对称密钥的安全生成：

•CA 证书：浏览器/操作系统自带，用于验证服务端的 TLS 证书的签名。保证服务端证书可信。

•TLS 证书：客户端和服务端使用 TLS 证书进行协商，以安全地生成一个对称密钥。

•如何验证证书主人的真实身份？权威CA机构

•如何验证签名？私钥加密，公钥解密

•向权威CA机构申请证书需要收费（也有短期免费的），如果所有通信全部在自家网站或APP内完成可以使用本地签名证书（即自己生成CA证书）



###### 生成本地签名证书

1.自己充当CA

​	1.生成CA的私钥

​	openssl genrsa -out ca.key 2048

​	2.生成CA证书(certificate, 缩写CRT)，有效期1000天

​	openssl req -x509 -new -nodes -key ca.key -subj "/CN=MaGeCA" -days 1000 -out ca.crt

​	CA证书里面包含了CA的信息和CA的签名(使用CA私钥加密)

2.由Server端生成证书签名请求(CertificateSigningRequest)

​	1.生成server的私钥（从私钥里可以提取出公钥）

​	openssl genrsa -out server.key 2048

​	2.编写证书签名请求()的配置文件csr.conf，指定加密算法、授信域名、申请者信息等，规范参考[ (openssl.org)](https://www.openssl.org/docs/man1.1.1/man5/)

​	3.根据配置文件和私钥，生成证书签名请求(包含了Server的公钥和一些身份信息)

​	openssl req -new -key server.key -config csr.conf -out server.csr

3.由CA签名，得到server的TLS证书，有效其365天。包含四部分：公钥+申请者信息 + 颁发者(CA)的信息+签名(使用 CA 私钥加密)

openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 365 -out server.crt



###### 客户端安装TLS证书

•将服务端的TLS证书添加到 OS 的默认证书列表中

•linux

sudo cp server.crt /usr/local/share/ca-certificates/server.crt sudo update-ca-certificates

•mac

打开钥匙串，把刚刚生成的server.crt 拖到证书一栏里即可

•编程：使用 HTTPS 客户端的 api 指定使用的 TLS 证书





##### websocket VS http

相似和关联：

•都是应用层协议，都基于tcp传输协议

•跟http有良好的兼容性，ws和http的默认端口都是80，wss和https的默认端口都是443

•websocket在握手阶段采用http发送数据

差异：

•http是半双工，而websocket通过多路复用实现了全双工

•http只能由client主动发起数据请求，而websocket还可以由server主动向client推送数据。在需要及时刷新的场景中，http只能靠client高频地轮询，浪费严重

•http是短连接(也可以实现长连接, HTTP1.1 的连接默认使用长连接)，每次数据请求都得经过三次握手重新建立连接，而websocket是长连接

•http长连接中每次请求都要带上header，而websocket在传输数据阶段不需要带header



##### websocket应用场景

WebSocket是HTML5下的产物，能更好的节省服务器资源和带宽

•html5多人游戏

•聊天室

•协同编辑

•基于实时位置的应用

•股票实时报价

•弹幕

•视频会议



##### websocket握手协议

* Request Header

Sec-Websocket-Version:13

Upgrade:websocket

Connection:Upgrade

Sec-Websocket-Key:duR0pUQxNgBJsRQKj2Jxsw==

* Response Header

Upgrade:websocket

Connection:Upgrade

Sec-Websocket-Accept:a1y2oy1zvgHsVyHMx+hZ1AYrEHI=

注：

•Upgrade:websocket和Connection:Upgrade指明使用WebSocket协议

•Sec-WebSocket-Version 指定Websocket协议版本

•Sec-WebSocket-Key是一个Base64 encode的值，是浏览器随机生成的

•服务端收到Sec-WebSocket-Key后拼接上一个固定的GUID，进行一次SHA-1摘要，再转成Base64编码，得到Sec-WebSocket-Accept返回给客户端。客户端对本地的Sec-WebSocket-Key执行同样的操作跟服务端返回的结果进行对比，如果不一致会返回错误关闭连接。如此操作是为了把websocket header跟http header区分开





##### WebSocket CS架构实现

###### go websocket API

•安装第三方包

go get github.com/gorilla/websocket

•将 http 升级到 WebSocket 协议

func (u *Upgrader) Upgrade(w http.ResponseWriter, r *http.Request, responseHeader http.Header) (*websocket.Conn, error) 

•客户端发起握手，请求连接

func (*websocket.Dialer) Dial(urlStr string, requestHeader http.Header) (*websocket.Conn, *http.Response, error)

type Upgrader struct {

   HandshakeTimeout time.Duration //websocket握手超时时间

   ReadBufferSize, WriteBufferSize int //io操作的缓存大小

   //http错误响应函数

   Error func(w http.ResponseWriter, r *http.Request, status int, reason error)

   //用于统一的链接检查，以防止跨站点请求伪造

   CheckOrigin func(r *http.Request) bool

}

•websocket发送的消息类型有5种：TextMessag,BinaryMessage, CloseMessag,PingMessage,PongMessage

•TextMessag和BinaryMessage分别表示发送文本消息和二进制消息

•CloseMessage关闭帧，接收方收到这个消息就关闭连接

•PingMessage和PongMessage是保持心跳的帧，发送方à接收方是PingMessage，接收方à发送方是PongMessage，目前浏览器没有相关api发送ping给服务器，只能由服务器发ping给浏览器，浏览器返回pong消息

•启动http服务

func http.ListenAndServe(addr string, handler http.Handler) error

•http.Handler需要实现接口

func ServeHTTP(w http.ResponseWriter, r *http.Request)







## day11

Go语言操作数据库



###### 实战建议

1. 写sql时一律使用小写
2. 那表时先判断表是否已存在   if not exists
3. 所有的列和表都加comment
4. 字符串长度比较短时尽量使用char，定长有篮球内存对齐，读写性能更好，而varchar字段频繁修改时容易产生内存碎片
5. 满足需求的前提下尽量使用短的数据类型，如tinyint vs int, float vs double, date vs datetime 

###### null

* default null 有别于default '' 和 default 0
* is null, is not null 有别于!='', !=0
* 尽量设为not null
  * 有些DB索引列不允许包含null
  * 对含中有null的列进行统计，结果可能不符合预期
  * Null值有时会严重拖慢系统性能



##### 规避慢查询

* 大部分的慢查询都是因为没有正确地使用索引
* 一次select不要超过1000行
* 分布查询limit m,n会检索前m+n行，只是返回后n行，通常用id>x来代替这种分布方式 where id>10000 limit 0, 1000
* 批量操作时最好一条sql语句搞定；其次打包成一个事务，一次性提交（高并发情况下减少对共享资源的争用）
* 不要使用连表操作，join逻辑在业务代码里完成





##### Go SQL驱动接口解读

###### database/sql接口

* Go官方没有提供数据库驱动，而是为开发数据库驱动定义了一些标准接口（即database/sql），开发者可以根据定义的接口来开发相应的数据库驱动
* Go中支持MySQL的驱动比较多，如
  * github.com/go-sql-driver/mysql 支持database/sql
  * github.com/ziutek/mymysql 支持database/sql，也支持自定义的接口
  * github.com/Philio/GoMySQL 不支持database/sql，自定义接口



###### 创建表结构

```
use test;
create table if not exists student(
	id int not null auto_increment comment '主键自增id',
	name char(10) not null comment '姓名',
	province char(6) not null comment '省',
	city char(10) not null comment '城市',
	addr varchar(100) default '' comment '地址',
	score float not null default 0 comment '考试成绩',
	enrollment date not null comment '入学时间',
	primary key (id), unique key idx_name (name),
	key idx_location (province, city)
)default CHARSET=utf8 comment '学员基本信息';
```

###### 使用go自带sql标准接口示例代码

```
// day11/common/tools.go
package common

import (
	"fmt"
	"os"
)

func CheckError(err error) {
	if err != nil {
		//stdout是行缓冲的，他的输出会放在一个buffer里面，只有到换行的时候，才会输出到屏幕。而stderr是无缓冲的，会直接输出
		fmt.Fprintf(os.Stderr, "fatal error: %s\n", err.Error())
		os.Exit(1)
	}
}


------
// day11/database/crud/main.go
package main

/*
基于go最原始api操作数据库
*/
package main

/*
基于go最原始api操作数据库
*/
import (
	"database/sql"
	"day11/common"
	"fmt"
	"time"

	_ "github.com/go-sql-driver/mysql"
)

var (
	loc *time.Location
)

func init() {
	loc, _ = time.LoadLocation("Asia/Shanghai")
}

// insert 插入数据
func insert(db *sql.DB) {
	//一条sql，插入2行记录
	res, err := db.Exec("insert into student (name,province,city,enrollment) values ('小明','深圳','深圳','2021-04-18'),('小红','上海','上海','2022-04-18')")
	common.CheckError(err)
	lastID, err := res.LastInsertId() //ID自增，用过的id（即使对应的行已delete）不会重复使用
	common.CheckError(err)
	fmt.Printf("after insert last id %d\n", lastID)
	rows, err := res.RowsAffected() //插入2行，所以影响2行
	common.CheckError(err)
	fmt.Printf("insert affect %d row\n", rows)
}

// replace 插入（覆盖）数据
func replace(db *sql.DB) {
	res, err := db.Exec("replace into student (name,province,city,enrollment) values ('小明','北京','北京','2021-04-18'),('小红','上海','上海','2022-04-18')")
	common.CheckError(err)
	lastID, err := res.LastInsertId() //ID自增，用过的id（即使对应的行已delete）不会重复使用
	common.CheckError(err)
	fmt.Printf("after replace last id %d\n", lastID) //id从0开始
	rows, err := res.RowsAffected()                  //替换2行(删除旧id2行，插入新id2行)，所以影响4行
	common.CheckError(err)
	fmt.Printf("replace affect %d row\n", rows)
}

// update 修改数据
func update(db *sql.DB) {
	res, err := db.Exec("update student set score=score+10 where city='上海'") //上海加10分
	common.CheckError(err)
	lastID, err := res.LastInsertId() //0, 仅插入操作才会给LastInsertId赋值
	common.CheckError(err)
	fmt.Printf("after update last id %d\n", lastID)
	rows, err := res.RowsAffected() //where city=?命中几行，就会影响几行
	common.CheckError(err)
	fmt.Printf("update affect %d row\n", rows)
}

// query 查询数据
func query(db *sql.DB) {
	rows, err := db.Query("select id,name,city,score from student where id > 2")
	common.CheckError(err)
	for rows.Next() { //没有数据或发生error时返回false
		var id int
		var score float32
		var name, city string
		err = rows.Scan(&id, &name, &city, &score) //通过scan把db里的数据赋给go变量
		common.CheckError(err)
		fmt.Printf("id=%d, score=%.2f, name=%s, city=%s \n", id, score, name, city)
	}
}

// delete 删除数据
func delete(db *sql.DB) {
	//一条sql，插入2行记录
	res, err := db.Exec("delete from student where id > 5 ") //上海加10分
	common.CheckError(err)
	rows, err := res.RowsAffected() //where city=?命中几行，就会影响几行
	common.CheckError(err)
	fmt.Printf("delete affect %d row\n", rows)
}

func main() {
	db, err := sql.Open("mysql", "jack:homsom@tcp(192.168.15.203:3306)/test?charset=utf8")
	common.CheckError(err)
	// insert(db)
	// replace(db)
	// update(db)
	// query(db)
	// delete(db)
}
```







###### Driver

* 注册数据库驱动
  * var d = Driver{proto: "tcp", raddr: "127.0.0.1:3306"}
  * sql.Register("mysql",d)

type Driver interface {

​	Open(name string) (Conn, error)

}

###### Conn

type Conn interface{

​	Prepare(query string) (Stmt, error)

​	Close() error

​	Begin() (Tx, error)

}

* 把一个查询query传给Prepare，返回Stmt(statement)
* Close关闭数据库连接
* Begin返回一个事务Tx(transaction)

###### Stmt

type Stmt interface{

​	Close() error

​	NumInput() int

​	Exec(args []Value) (Result, error)

​	Query(args []Value) (Rows, error)

}

* Close关闭当前的链接状态
* NumInput返回当前预留参数的个数
* Exec执行Prepare准备好的sql，传入参数执行update/insert等操作，返回Result数据
* Query执行Prepare准备好的sql，传入需要的参数执行select操作，返回Rows的结果集

###### Tx

type Tx interface{

​	Commit() error

​	Rollback() error

}

* Commit 提交事务
* Rollback回滚事务

###### Result

type Result interface{

​	LastInsertId() (int64, error)

​	RowsAffected() (int64, error)

}

* LastInsertId返回由数据库执行插入操作得到的自增ID号
* RowsAffected返回操作影响的数据条目数



###### RowsAffected

type RowsAffected int64

func (RowsAffected) LastInsertId() (int64, error)

func (v RowsAffected) RowsAffected() (int64, error)

* RowsAffected是int64的别名，它实现了Result接口

###### Rows

type Rows interface{

​	Columns() []string

​	Close() error

​	Next(dest []Value) error

}

* Columns是查询所需要的字段
* Close关闭迭代器
* Next返回下一条数据，把数据赋值给dest， dest里面的元素必须是driver.Value的值。如果最后没数据了，Next函数返回io.EOF

###### Value

type Value interface{}

* Value要么是nil，要么是下面的任意一种
  * int64
  * float64
  * bool
  * []byte
  * stirng
  * time.Time

###### ValueConverter

type ValueConverter interfce {

​	ConvertValue(v interface{}) (Value, error)

}

* 把数据库里的数据类型转换成Value允许的数据类型







##### 通过Stmt执行操作

###### Stmt

* 定义一个sql模板

stmt, err := db.Prepare("update student set score=score+? where city=?")

* 多次使用模板

res, err := stmt.Exec(10, "上海")

res, err = stmt.Exec(9, "深圳")



###### sql注入

example 1:

* sql = "select username,password from user where username='" + username + "' and password='" + password + "'";
* 变量username和password从前端输入框获取，如果用户输入的username为lily, password为aaa' or '1' = '1'
* 则完整的sql为select username,password from user where username='lily' and password='aaa' or '1' = '1'
* 会返回表里的所有记录，如果记录数大于0就允许登录，则lily的账号被盗

example 2:

* sql = "insert into student (name) values ('" + username + "')";
* 变量username从前端输入框获取，如果用户输入的username为lily');drop table student; --
* 完整sql为insert into student (name) values ('lily'); drop table student;--'
* 通过注释符--屏蔽掉了末尾的'),删除了整个表



###### 防止sql注入

* 前端输入要加正则校验、长度限制
* 对特殊符号（<>&*;'"等）进行转义或编码转换(JSP处理，或后端处理)，Go的text/template包里面的HTMLEscapeString函数可以对字符串进行转义处理。
* 不要将用户输入直接嵌入到sql语句中，而应该使用参数化查询接口，如Prepare、Query、Exec（query string, args ...interface{})
* 使用专业的SQL注入检测工具进行检测，如sqlmap、SQLninja
* 避免网站打印出SQL错误信息，以防止攻击者利用这些错误信息进行SQL注入



###### SQL预编译

* DB执行sql分为3步:
  * 词法和语义解析
  * 优化SQL语句，制定执行计划
  * 执行并返回结果
* SQL预编译技术是指将用户输入用占位符?代替，先对这个模板化的sql进行预编译，实际运行时再将用户输入代入
* 除了可以防止SQL注入，还可以对预编译的SQL语句进行缓存，之后的运行就省去了解析优化SQL语句的过程



###### Stmt代码示例

```
package main

/*
基于go最原始api操作数据库
*/
import (
	"database/sql"
	"day11/common"
	"fmt"
	"strconv"
	"time"

	_ "github.com/go-sql-driver/mysql"
)

const (
	TIME_LAYOUT = "20060102"
)

var (
	loc *time.Location
)

func init() {
	loc, _ = time.LoadLocation("Asia/Shanghai")
}

// insert 通过stmt插入数据
func insert(db *sql.DB) {
	//一条sql，插入2行记录
	stmt, err := db.Prepare("insert into student (name,province,city,enrollment) values (?,?,?,?),(?,?,?,?)")
	common.CheckError(err)
	date1, err := time.ParseInLocation(TIME_LAYOUT, "2021-03-18", loc)
	common.CheckError(err)
	date2, err := time.ParseInLocation(TIME_LAYOUT, "2021-03-31", loc)
	common.CheckError(err)
	res, err := stmt.Exec("小明", "深圳", "深圳", date1, "小红", "上海", "上海", date2)
	common.CheckError(err)
	lastID, err := res.LastInsertId() //ID自增，用过的id（即使对应的行已delete）不会重复使用
	common.CheckError(err)
	fmt.Printf("after insert last id %d\n", lastID)
	rows, err := res.RowsAffected() //插入2行，所以影响2行
	common.CheckError(err)
	fmt.Printf("insert affect %d row\n", rows)
}

// replace 通过stmt插入（覆盖）数据
func replace(db *sql.DB) {
	//由于name字段上有唯一索引,insert重复的name会报错.而使用replace会先删除,再插入
	stmt, err := db.Prepare("replace into student (name,province,city,enrollment) values (?,?,?,?),(?,?,?,?)")
	common.CheckError(err)
	//字符串解析为时间,注意要使用time.ParseInLocation()函数指定时区,time.Parse()函数使用默认的UTS时区
	date1, err := time.ParseInLocation(TIME_LAYOUT, "2021-04-18", loc)
	common.CheckError(err)
	date2, err := time.ParseInLocation(TIME_LAYOUT, "2021-05-31", loc)
	common.CheckError(err)
	fmt.Printf("day of 2021-04-26 is %d\n", date2.Local().Day())
	res, err := stmt.Exec("小明", "深圳", "深圳", date1, "小红", "上海", "上海", date2)
	common.CheckError(err)
	lastID, err := res.LastInsertId() //ID自增，用过的id（即使对应的行已delete）不会重复使用
	common.CheckError(err)
	fmt.Printf("after insert last id %d\n", lastID)
	rows, err := res.RowsAffected() //插入2行，所以影响2行
	common.CheckError(err)
	fmt.Printf("insert affect %d row\n", rows)
}

// update 通过stmt修改数据
func update(db *sql.DB) {
	stmt, err := db.Prepare("update student set score=score+? where city=?") //上海加10分
	common.CheckError(err)
	res, err := stmt.Exec(10, "上海")
	common.CheckError(err)
	res, err = stmt.Exec(9, "深圳")
	common.CheckError(err)
	lastID, err := res.LastInsertId() //0, 仅插入操作才会给LastInsertId赋值
	common.CheckError(err)
	fmt.Printf("after update last id %d\n", lastID)
	rows, err := res.RowsAffected() //where city=?命中几行，就会影响几行
	common.CheckError(err)
	fmt.Printf("update affect %d row\n", rows)
}

// query 通过stmt查询数据
func query(db *sql.DB) {
	stmt, err := db.Prepare("select id,name,city,score from student where id > ?")
	common.CheckError(err)
	rows, err := stmt.Query(2)
	for rows.Next() { //没有数据或发生error时返回false
		var id int
		var score float32
		var name, city string
		err = rows.Scan(&id, &name, &city, &score) //通过scan把db里的数据赋给go变量
		common.CheckError(err)
		fmt.Printf("id=%d, score=%.2f, name=%s, city=%s \n", id, score, name, city)
	}
}

// delete 通过stmt删除数据
func delete(db *sql.DB) {
	//一条sql，插入2行记录
	stmt, err := db.Prepare("delete from student where id > ? ") //上海加10分
	common.CheckError(err)
	res, err := stmt.Exec(5)
	common.CheckError(err)
	rows, err := res.RowsAffected() //where city=?命中几行，就会影响几行
	common.CheckError(err)
	fmt.Printf("delete affect %d row\n", rows)
}

func hugeInsert(db *sql.DB) {
	stmt, err := db.Prepare("insert into student (name,province,city,enrollment) values (?,?,?,?)")
	common.CheckError(err)
	date, err := time.ParseInLocation("20060102", "20211204", loc)
	for i := 0; i < 100000; i++ {
		stmt.Exec("曹操"+strconv.Itoa(i), "河南", "许昌", date)
	}

}

// traversel1通过limit offset,n遍历表
func traverse1(db *sql.DB) {
	var offset int
	begin := time.Now()
	stmt, _ := db.Prepare("select id,name,province from student limit ?,100")
	for i := 0; i < 100; i++ {
		t0 := time.Now()
		rows, _ := stmt.Query(offset)
		offset += 100
		fmt.Println(i, time.Since(t0))

		for rows.Next() {
			var id int
			var name, province string
			rows.Scan(&id, &name, &province)
		}
	}
	fmt.Println("total:", time.Since(begin))
}

// traversel2通过limit offset n遍历表,推荐这种
func traverse2(db *sql.DB) {
	var maxid int
	begin := time.Now()
	stmt, _ := db.Prepare("select id,name,province from student where id > ? limit 100")
	for i := 0; i < 100; i++ {
		t0 := time.Now()
		rows, _ := stmt.Query(maxid)
		fmt.Println(i, time.Since(t0))

		for rows.Next() {
			var id int
			var name, province string
			rows.Scan(&id, &name, &province)
			if id > maxid {
				maxid = id
			}
		}
	}
	fmt.Println("total:", time.Since(begin))
}

func main() {
	db, err := sql.Open("mysql", "jack:homsom@tcp(192.168.15.203:3306)/test?charset=utf8")
	common.CheckError(err)
	// insert(db)
	// replace(db)
	// update(db)
	// query(db)
	// delete(db)
	// hugeInsert(db)
	traverse1(db) //此方式慢,每次蚁指定的起始和结束位,如果查询10000,100,则会查询10100行
	traverse2(db) //此方式查询块,每次查询前100行,此查询每次只查询100行
}
```







#### ORM与NoSQL技术

1. 开源工具SQLBuilder介绍
2. 自己封装SQL构建器
3. ORM技术与GORM
4. Go操作MongoDB



##### 开源SQLBuilder

- Go-SQLBuilder是一个用于创建SQL语句的工具函数库，提供一系列灵活的、与原生SQL语法一致的链式函数。归属于艾润物联公司
- go get -u github.com/parkingwang/go-sqlbuilder
- Gendry是一个用于辅助操作数据库的Go包。基于go-sql-driver/mysql，它提供了一系列的方法来为你调用标准库database/sql中的方法准备参数
- go get -u github.com/didi/gendry

###### Go-SQLBuilder

```
// Go-SQLBuilder函数链，不带执行函数，需要调用原始Query()
sql := gsb.NewContext().
	Select("id","name","score","city").
	From("student").
	OrderBy("score").DESC().
	Column("name").ASC().
	Limit(10).Offset(20).
	ToSQL()
	
// Gendry函数链，带执行函数
where := map[string]interface{}{
	"city": []string{"北京","上海","广州"}，
	“score<": 30,
	"addr": builder.IsNotNull,
	"_orderby": "score desc",
}
fields := []string{"id","name","city","score"}
//查询表、查询条件、显示字段，最后执行select
_,_,err := builder.BuildSelect("student", where, fields)
```



##### 自己封装SQL构建器

 ```
 package main
 
 import (
 	"fmt"
 	"strconv"
 	"strings"
 )
 
 // Builder 根据一个函数生成一小段sql
 // select, where, limit,orderby 这些都是Builder
 type Builder interface {
 	toString() string
 	getPrev() Builder
 }
 
 type LimitBuilder struct {
 	sb   strings.Builder
 	prev Builder
 }
 
 func newLimitBuilder(offset, n int) *LimitBuilder {
 	builder := &LimitBuilder{}
 	//通过strings.Builder实现高效的字符串连接
 	builder.sb.WriteString(" limit ")
 	builder.sb.WriteString(strconv.Itoa(offset))
 	builder.sb.WriteString(",")
 	builder.sb.WriteString(strconv.Itoa(n))
 	return builder
 }
 
 func (self *LimitBuilder) toString() string {
 	return self.sb.String()
 }
 
 func (self *LimitBuilder) getPrev() Builder {
 	return self.prev
 }
 
 func (self *LimitBuilder) ToString() string {
 	var root Builder
 	root = self                 //因为self不能变，所以用root承接转换
 	for root.getPrev() != nil { //找到最前面的root Builder
 		root = root.getPrev()
 	}
 	return root.toString()
 }
 
 type OrderByBuilder struct {
 	sb    strings.Builder
 	limit *LimitBuilder
 	prev  Builder
 }
 
 func newOrderByBuilder(column string) *OrderByBuilder {
 	builder := &OrderByBuilder{}
 	builder.sb.WriteString(" order by ")
 	builder.sb.WriteString(column)
 	return builder
 }
 
 func (self *OrderByBuilder) getPrev() Builder {
 	return self.prev
 }
 
 func (self *OrderByBuilder) toString() string {
 	if self.limit != nil {
 		self.sb.WriteString(self.limit.toString())
 	}
 	return self.sb.String()
 }
 
 func (self *OrderByBuilder) ToString() string {
 	var root Builder
 	root = self
 	for root.getPrev() != nil {
 		root = root.getPrev()
 	}
 	return root.toString()
 }
 
 func (self *OrderByBuilder) Asc() *OrderByBuilder {
 	self.sb.WriteString(" asc")
 	return self
 }
 
 func (self *OrderByBuilder) Desc() *OrderByBuilder {
 	self.sb.WriteString(" desc")
 	return self
 }
 
 func (self *OrderByBuilder) Limit(offset, n int) *LimitBuilder {
 	limit := newLimitBuilder(offset, n)
 	limit.prev = self
 	self.limit = limit
 	return limit
 }
 
 type WhereBuilder struct {
 	sb      strings.Builder
 	orderby *OrderByBuilder
 	limit   *LimitBuilder
 	prev    Builder
 }
 
 func newWhereBuilder(condition string) *WhereBuilder {
 	builder := &WhereBuilder{}
 	builder.sb.WriteString(" where ")
 	builder.sb.WriteString(condition)
 	return builder
 }
 
 func (self *WhereBuilder) getPrev() Builder {
 	return self.prev
 }
 
 func (self *WhereBuilder) toString() string {
 	if self.orderby != nil {
 		self.sb.WriteString(self.orderby.toString())
 	}
 	if self.limit != nil {
 		self.sb.WriteString(self.limit.toString())
 	}
 	return self.sb.String()
 }
 
 func (self *WhereBuilder) ToString() string {
 	var root Builder
 	root = self
 	for root.getPrev() != nil {
 		root = root.getPrev()
 	}
 	return root.toString()
 }
 
 func (self *WhereBuilder) Orderby(column string) *OrderByBuilder {
 	orderby := newOrderByBuilder(column)
 	orderby.prev = self
 	self.orderby = orderby
 	return orderby
 }
 
 func (self *WhereBuilder) Limit(offset, n int) *LimitBuilder {
 	limit := newLimitBuilder(offset, n)
 	limit.prev = self
 	self.limit = limit
 	return limit
 }
 
 func (self *WhereBuilder) And(condition string) *WhereBuilder {
 	self.sb.WriteString(" and ")
 	self.sb.WriteString(condition)
 	return self
 }
 
 func (self *WhereBuilder) Or(condition string) *WhereBuilder {
 	self.sb.WriteString(" or ")
 	self.sb.WriteString(condition)
 	return self
 }
 
 type SelectBuilder struct {
 	sb    strings.Builder
 	table string
 	where *WhereBuilder
 }
 
 func NewSelectBuilder(table string) *SelectBuilder {
 	builder := &SelectBuilder{
 		table: table,
 	}
 	builder.sb.WriteString("select ")
 	return builder
 }
 
 func (self *SelectBuilder) Column(columns string) *SelectBuilder {
 	self.sb.WriteString(columns)
 	self.sb.WriteString(" from ")
 	self.sb.WriteString(self.table)
 	return self
 }
 
 func (self *SelectBuilder) Where(condition string) *WhereBuilder {
 	where := newWhereBuilder(condition)
 	self.where = where
 	where.prev = self
 	return where
 }
 
 func (self *SelectBuilder) toString() string {
 	if self.where != nil {
 		self.sb.WriteString(self.where.toString())
 	}
 	return self.sb.String()
 }
 
 func (self *SelectBuilder) getPrev() Builder {
 	return nil
 }
 
 func (self *SelectBuilder) ToString() string {
 	var root Builder
 	root = self
 	for root.getPrev() != nil {
 		root = root.getPrev()
 	}
 	return root.toString()
 }
 
 func main() {
 	sql := NewSelectBuilder("student").Column("id,name,city").
 		Where("id>0").
 		And("city='许昌'").
 		Or("city='北京'").
 		Orderby("name").Desc().
 		Limit(0, 10).
 		ToString()
 	fmt.Println(sql)
 }
 ```



##### ORM技术与GORM

ORM

* ORM即Object Relational Mapping，对象关系映射
* Relational指各种sql类的关系型数据库
* Object指面向对象编程(object-oriented rogramming)中的对象
* ORM在数据库记录和程序对象之间做一层映射转换，使程序中不用再去编写原生SQL，而是面向对象的思想去编写类、对象、调用相应的方法来完成数据库操作

GORM

* go get -u gorm.io/gorm
* go get -u gorm.io/driver/mysql
* GORM是一个全能的、友好的、基于golang的ORM库
* GORM倾向于约定，而不是配置。默认情况下，GORM使用ID作为主键，使用结构体名的【蛇形复数】作为表名，字段名的【蛇形】作为列名，并使用CreatedAt、UpdatedAt字段追踪创建、更新时间
* 驼峰命名：UpdateAt
* 蛇形命名：update_at

```
dsn := "root:@tcp(127.0.0.1:3306)/test?charset=utf8mb4&parseTime=True"
db,err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
student := Student{Name: "光绪",Province: "北京",City: "北京",Score: 38,Enrollment: time.now()}
db.Create(&student)
```



```
//go get gorm.io/gorm
//go get gorm.io/driver/mysql

package main

import (
	"fmt"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

//对应到"students"这个表名
type Student struct {
	Ids  int     `gorm:"column:id;primaryKey"` // students表的字段id, Ids对应主键 id字段
	Name string  // name
	Rank float32 `gorm:"column:score"` // score
	// Score float32 // score
	// UpdateAt time.Time //update_at
	// Province string // province
}

// 将Student的表名对应student，如果不写TableName()，则默认对应的表名是students(带s复数),而真实表名只有student
func (Student) TableName() string {
	return "student"
}

// 查询
func query(db *gorm.DB) {
	var student Student
	db.Where("score=?", 0).Take(&student) //随机取一个字段
	// db.Where("score=?", 0).Last(&student)
	fmt.Println(student.Ids)
	fmt.Println(student.Name)
	fmt.Println(student.Rank)

	var students []Student
	db.Where("city in ?", []string{"北京", "上海"}).Find(&students) //find查询多行
	for _, student := range students {
		fmt.Println(student.Ids)
		fmt.Println(student.Name)
		fmt.Println(student.Rank)
	}

	student = Student{}                  //单选接收结构
	students = []Student{}               //多行接收结构
	db.Find(&students, []int{8, 12, 56}) // where id in(8,12,56), 默认使用主键id
	for _, student := range students {
		fmt.Println(student.Ids)
	}

	students = []Student{}                                   //多行接收结构，清空
	db.Select("id,name,score").Where(map[string]interface{}{ //select显示字段
		"city":  []string{"北京", "上海"}, //city in
		"score": 0,                    //score =
	}).Or("addr is not null").Order("score desc").Find(&students).Limit(10)
	for _, student := range students {
		fmt.Println(student.Ids)
		fmt.Println(student.Name)
		fmt.Println(student.Rank)
	}
}

func insert(db *gorm.DB) {
	student := Student{Ids: 2, Name: "abc", Rank: 100}
	db.Create(&student) //插入1行

	arr := []Student{student, student, student}
	db.Create(arr)                //插入多行
	db.CreateInBatches(arr, 1000) //如果arr有10000行，分批插入，每次1000行
}

func update(db *gorm.DB) {
	var student Student
	//更新Student{}这个表，set city="北京" where score=100，更新一列
	db.Model(&student).Where("score=100").Update("city", "北京")
	//更新Student{}这个表，set city="北京",province="北京" where score=100，更新多列
	db.Model(&student).Where("score=100").Updates(map[string]interface{}{
		"city":     "北京",
		"province": "北京",
	})

	student.Ids = 8
	db.Model(&student).Update("city", "北京") //where id=8 set city="北京"
}

func delete(db *gorm.DB) {
	var student Student
	//删除student结构体对应的表中city in ("北京", "上海")
	db.Where("city in ?", []string{"北京", "上海"}).Delete(&student)

	student.Ids = 8
	// delete from student where id=8
	db.Delete(&student)
}

// 事务，原子操作
func transaction(db *gorm.DB) {
	tx := db.Begin()
	for i := 0; i < 100; i++ {
		student := Student{Ids: 2, Name: "abc", Rank: 100}
		db.Create(&student) //插入1行
	}
	tx.Commit()
}

func main() {
	dsn := "jack:homsom@tcp(192.168.15.203:3306)/test?charset=utf8mb4&parseTime=True"
	db, _ := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	query(db)
}
```





##### MongoDB

* NoSQL泛指非关系型数据库，如mongo, redis, HBase
* mongo使用高效的二进制数据存储，文件存储格式为BSON（一种json的扩展，比json性能更好，功能更强大）
* MySQL中表的概念在mongo里叫集合(collection)，MySQL中行的概念在mongo中叫文档(document)，一个文档看上去像一个json



###### 运行mogodb

```console
docker run -d --name mongodb --restart always \
	-e MONGO_INITDB_ROOT_USERNAME=mongoadmin \
	-e MONGO_INITDB_ROOT_PASSWORD=homsom \
	-p 27017:27017 \
	-v /data/mongodb/db:/data/db \
	mongo:6.0.3

& docker ps -a 
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                      NAMES
b1ae3382a6fc        mongo:6.0.3         "docker-entrypoint.s…"   3 seconds ago       Up 2 seconds        0.0.0.0:27017->27017/tcp   mongodb

```



###### mongo常用命令

* use test; 	切换test库，如果没有则创建
* db.createUser({user: "tester", pwd: "123456", roles: [{role: "dbAdmin", db: "test"}]});   //创建用户
* db.createCollection("student");   创建collection
* db.student.createIndex({"name": 1});    在name上创建索引，不是唯一索引，1升序, -1降序
* db.student.insertOne({name: "张三", city: "北京"});   插入一行
* db.student.find({name: "张三"});    查询用户
* db.student.find();   查询所有
* db.student.update({name: "张三"}, {name: "张三", city: "上海"});
* db.student.deleteOne({name: "张三"});  删除一行，不要One则可以删除多行



###### 安装go mongo-driver

* go get go.mongodb.org/mongo-driver
* go get go.mongodb.org/mongo-driver/x/bsonx/bsoncore@v1.7.1
* go get go.mongodb.org/mongo-driver/x/mongo/driver@v1.7.1
* go get go.mongodb.org/mongo-driver/mongo/options@v1.7.1
* go get go.mongodb.org/mongo-driver/x/mongo/driver/topology@v1.7.1
* go get go.mongodb.org/mongo-driver/mongo@v1.7.1

###### 连接db

```
option := options.Client().ApplyURI("mongodb://192.168.15.203:27017").
	SetConnectTimeout(time.Second).
	SetAuth(option.Credential{Username: "mongoadmin",Password: "homsom", AuthSource: "test"})	//指定用户名和密码、AuthSource代表Database
client,err := mongo.Connect(context.Background(), option)
err = client.Pring(ctx, nil)	//注意: Ping成功才代表连接成功
```

###### 查询mongo

```
sort := base.D{{"name", 1}}	//1升序，-1降序
filter := bson.D{{"score",bson.D{{"&gt", 3}}}} //score > 3
findOption := options.Find()
findOption.SetSort(sort)	//按name升序排序
findOption.SetLimit(10)		//最多返回10个
findOption.SetSkip(3)	//跳过前3个
cursor,err := collection.Find(ctx, filter, findOption)
```



###### 代码

```
package main

/*
go get go.mongodb.org/mongo-driver
go get go.mongodb.org/mongo-driver/x/bsonx/bsoncore
go get go.mongodb.org/mongo-driver/x/mongo/driver
go get go.mongodb.org/mongo-driver/mongo/options
go get go.mongodb.org/mongo-driver/x/mongo/driver/topology
go get go.mongodb.org/mongo-driver/mongo

db.createUser({user: "tester", pwd: "123456", roles: [{role: "dbAdmin", db: "test"}]});
db.grantRolesToUser("tester", [ { role: "readWrite", db: "test" } ]);
*/

import (
	"fmt"
	"os"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"golang.org/x/net/context"
)

type Student struct {
	Name  string // name
	City  string
	Score float32
}

func CheckError(err error) {
	if err != nil {
		//stdout是行缓冲的，他的输出会放在一个buffer里面，只有到换行的时候，才会输出到屏幕。而stderr是无缓冲的，会直接输出
		fmt.Fprintf(os.Stderr, "fatal error: %s\n", err.Error())
		os.Exit(1)
	}
}

func create(ctx context.Context, collection *mongo.Collection) {
	//插入一个doc
	doc := Student{Name: "张三", City: "北京", Score: 39}
	res, err := collection.InsertOne(ctx, doc)
	CheckError(err)
	fmt.Printf("insert id %d doc\n", res.InsertedID) //每个doc都会有一个全世界唯一的ID(时间+空间唯一)

	//插入多个docs
	docs := []interface{}{Student{Name: "张三", City: "北京", Score: 39}, Student{Name: "张三", City: "北京", Score: 39}}
	manyRes, err := collection.InsertMany(ctx, docs)
	CheckError(err)
	fmt.Printf("insert %d doc\n", manyRes.InsertedIDs)
}

func query(ctx context.Context, client *mongo.Client) {
	collection := client.Database("test").Collection("student")
	filter := bson.D{{"score", bson.D{{"&gt", 3}}}} //score >3
	findOption := options.Find()
	sort := bson.D{{"name", 1}}
	findOption.SetSort(sort)
	findOption.SetLimit(10)
	cursor, err := collection.Find(ctx, filter, findOption)
	CheckError(err)
	for cursor.Next(ctx) {
		var stu Student
		cursor.Decode(&stu)
	}
}

func delete(ctx context.Context, collection *mongo.Collection) {
	filter := bson.D{{"name", "张三"}}
	res, err := collection.DeleteMany(ctx, filter)
	CheckError(err)
	fmt.Printf("delete %d doc\n", res)
}

func update(ctx context.Context, collection *mongo.Collection) {
	filter := bson.D{{"city", "北京"}}
	update := bson.D{{"$inc", bson.D{{"score", 5}}}}       //increment,让score+5
	res, err := collection.UpdateMany(ctx, filter, update) //多行更新
	CheckError(err)
	fmt.Printf("update %d doc\n", res)
}

func main() {
	var ctx context.Context
	option := options.Client().ApplyURI("mongodb://192.168.15.203:27017").SetConnectTimeout(time.Second * 2).
		SetAuth(options.Credential{Username: "tester", Password: "123456", AuthSource: "test"})
	// option := options.Client().ApplyURI("mongodb://192.168.15.203:27017").SetConnectTimeout(time.Second * 2).
	// 	SetAuth(options.Credential{Username: "mongoadmin", Password: "homsom", AuthSource: "test"})
	client, _ := mongo.Connect(ctx, option)
	err := client.Ping(ctx, nil)
	if err == nil {
		fmt.Println("连接mongo成功")
		defer client.Disconnect(ctx)
	} else {
		fmt.Println("连接mongo失败")
		return
	}
	query(ctx, client)

}
```







## day12



### Go语言http标准库解读

1. http协议
2. go语言http标准库
3. http router
4. 请求校验
5. http中间件
6. 打造自己的web框架



#### http协议

* http：超文本传输协议Hyper Text Transfer Protocol
* http属于应用层协议，它在传输层用的是Tcp协议
* 无状态，对事务处理没有记忆能力（对比TCP协议里的确认号）。如果要保存状态需要引用其他技术。如cookie
* 无连接，每次连接只处理一个请求。早期带宽和计算资源有限，这么做是为了追求传输速度快，后来通过Connection: Keep-Alive实现长连接。http1.1废弃了Keep-Alive，默认支持长连接。



###### 请求方法

http 1.0 和 http 1.1版本，http1.1兼容http1.0请求方法

```
// http 1.0
GET: 请求获取Request-URI所标识的资源
POST: 向URI提交数据（例如提交表单或上传数据）
HEAD: 类似于GET，返回的响应中没有具体的内容，用于获取报头
// http 1.1
PUT: 对服务器上已存在的资源进行更新
DELETE: 请求服务器删除指定的页面
CONNECT: HTTP/1.1预留，能够将连接改为管道方式的代理服务器
OPTIONS: 查看服务端性能
TRACE: 回显服务器收到的请求，主要用于测试或诊断
PATCH: 同PUT，可只对资源的一部分更新，资源不存在时会创建

* 实际中server对各种request method的处理方式可能不是按协议标准来的，比如server收到PUT请求时偏偏执行DELETE操作，同理仅用一个GET方法也能实现增删改查的全部功能
* 大多数浏览器只支持GET和POST
```



###### URL

* URI：uniform resource identifier，统一资源标识符，用来唯一的标识 一个资源
* URL：uniform resource locator，统一资源定位器，它是一种具体的URI，指明了如何 locate这个资源
* URL举例：
  * http://www.qq.com:8080/news/tech/43253.html?id=431&name=tech123#pic    //#pic为锚点 



###### 请求头

| Header          | 解释                                                         | 示例                                            |
| --------------- | ------------------------------------------------------------ | ----------------------------------------------- |
| Accept          | 指定客户端能够接收的内容类型                                 | Accept: text/plain, text/html                   |
| Accept-Charset  | 浏览器可以接受的字符编码集                                   | Accept-Charset: iso-8859-5                      |
| Accept-Encoding | 指定浏览器可以支持的web服务器返回内容压缩编码类型            | Accept-Encoding: compress, gzip                 |
| Accept-Language | 浏览器可授受的语言                                           | Accept-Language: en, zh                         |
| Authorization   | HTTP授权的授权证书                                           | Authorization: Basic AFLAJOIEFsljakfksjafjafa== |
| Cache-Conntrol  | 指定请求和响应遵循的缓存机制                                 | Cache-Control: no-cache                         |
| Connection      | 表示是否需要持久连接（HTTP 1.1默认进行持久连接）             | Connection: close                               |
| Cookie          | HTTP请求发送时，会把保存在该请求域名下的所有cookie值一起发送给web服务器 | Cookie: $Version=1;Skin=new;                    |
| Content-Length  | 请求的内容长度                                               | Content-Length: 3498                            |
| Content-Type    | 指定正文（body）的数据格式                                   | Content-Type: application/x-www-form-urlencoded |
| User-Agent      | 浏览器信息                                                   | Mozilla/5(Windows NT6.1;Win64;x64)              |

###### Content-Type

* application/x-www-form-urlencoded

  * 浏览器的原生form表单，如果不设置Content-Type属性，则默认以application/x-www-form-urlencoded方式传输数据
  * 正文例如：name=manu&message=this_is_great

* multipart/form-data

  * 上传文件时使用multipart/form-data，支持多种文件格式
  * 正文例如：name="text"name="file";filename="chrome.png"Content-type: image/png.. content of chrome.org

* application/json

  * 正文例如：{"title":"test","sub":[1,2,3]}

* text/xml:

  * 正文例如：

    ```
    <?xml version="1.0"?><methodCall>
    <methodName>examples.getStateName</methodName>
    </methodCall>
    ```

    

###### 请求正文

* GET请求没有请求正文
* POST可以包含GET

```
POST ／post?id=1234&page=1 HTTP/1.1
Content-Type: application/x-www-form-urlencoded

name=manu&message=this_is_great
```



###### GET和POST的区别

* get的请求参数全部在url里，参数变时url就变；post可以把参数放到请求正文里，参数变时url不变
* 虽然http协议并没有对url和请求正文做长度限制，但在实际中浏览器对url的长度限制比请求正文要小很多，所以post可以提交的数据比get要大得多
* get比post更容易受到攻击（源于get的参数直接暴露在url里）



###### 响应信息中的状态及话术

| code | phrase                | 说明                               |
| ---- | --------------------- | ---------------------------------- |
| 200  | Ok                    | 请求成功                           |
| 400  | Bad Request           | 客户端有语法错误，服务端不理解     |
| 401  | Unauthorized          | 请求未经授权                       |
| 403  | Forbidden             | 服务端拒绝提供服务                 |
| 404  | Not Found             | 请求资源不存在                     |
| 500  | Internal Server Error | 服务器发生不可预期的错误           |
| 503  | Server Unavailable    | 服务器当前有问题，过段时间可能恢复 |

###### 响应头

| Header           | 解释                             | 示例                                  |
| ---------------- | -------------------------------- | ------------------------------------- |
| Allow            | 对某网络资源的有效的请求行为     | Allow: GET,HEAD                       |
| Date             | 原始服务器消息发出的时间         | Date: Tue,15 Nov 2010 08:12:31 GMT    |
| Content-Encoding | 服务器支持的返回内容压缩编码类型 | Content-Encoding: gzip                |
| Content-Language | 响应体的语言                     | Content-Language: en,zh               |
| Content-Length   | 响应体的长度                     | Content-Length: 348                   |
| Cache-Control    | 指定请求和响应遵循的缓存机制     | Cache-Control: no-cache               |
| Content-Type     | 返回内容的MIME类型               | Content-Type: text/html;charset=utf-8 |



#### go语言http标准库

##### http server

```
package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
)

type MyHandler struct{}

func (MyHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "hello boy")
}

func HelloHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Printf("method: %s\n", r.Method)
	fmt.Printf("host: %s\n", r.Host)
	fmt.Printf("url: %s\n", r.URL)
	fmt.Printf("proto: %s\n", r.Proto)
	fmt.Printf("req header\n")
	for k, v := range r.Header {
		fmt.Printf("%s: %s\n", k, v)
	}
	fmt.Println("req body")
	io.Copy(os.Stdout, r.Body)
	os.Stdout.WriteString("\n")
	fmt.Fprint(w, "hello boy") //Fprint = follow print,把返回的内容写入到http.ResponseWriter
}

func HelloHandlergirl(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "hello girl") //Fprint = follow print
}

func main() {
	//方法1,访问此端口只能由1个函数处理
	// http.ListenAndServe(":5656", MyHandler{})

	//方法2,访问此端口的多个目录可以由多个函数处理
	http.HandleFunc("/", HelloHandler) //路由，请求到目录时去执行HelloHandler
	http.HandleFunc("/g", HelloHandlergirl)
	//ListenAndServe如果不发生error会一直阻塞。为每一个请求创建一个协程去处理。
	http.ListenAndServe(":5656", nil)
}

```

##### http client

```
package main

import (
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"
)

func get() {
	if resp, err := http.Get("http://127.0.0.1:5656/g"); err != nil {
		panic(err)
	} else {
		//注意一定要调用resp.Body.Close()，否则会协和泄露（同时引发内存泄漏）
		defer resp.Body.Close()
		io.Copy(os.Stdout, resp.Body) //把resp.Body输出到标准输出流
		os.Stdout.WriteString("\n")
	}
}

func post() {
	reader := strings.NewReader("hello server")
	if resp, err := http.Post("http://127.0.0.1:5656", "text/plain", reader); err != nil {
		panic(err)
	} else {
		defer resp.Body.Close()
		fmt.Printf("proto: %s\n", resp.Proto)
		fmt.Printf("status: %s\n", resp.Status)
		fmt.Printf("resp header\n")
		for k, v := range resp.Header {
			fmt.Printf("%s: %s\n", k, v)
		}
		fmt.Println("resp body")
		io.Copy(os.Stdout, resp.Body)
		os.Stdout.WriteString("\n")
	}
}

// 自定义请求
func doRequest() {
	reader := strings.NewReader("hello server")
	//可以使用post、get方法请求，get请求时可以传入body，服务端也会获取到
	if req, err := http.NewRequest("get", "http://127.0.0.1:5656", reader); err != nil {
		panic(err)
	} else {
		req.Header.Add("User-Agent", "12345")
		req.Header.Add("key", "golang")
		//定义一个cookie
		req.AddCookie(&http.Cookie{
			Name:   "auth",
			Value:  "here is password",
			Path:   "/",
			Domain: "localhost",
		})

		// 新建客户端，期待客户端500ms拿到响应
		client := http.Client{Timeout: 500 * time.Millisecond}
		// 客户端执行自定义请求
		if resp, err := client.Do(req); err != nil {
			panic(err)
		} else {
			defer resp.Body.Close()
			fmt.Printf("proto: %s\n", resp.Proto)
			fmt.Printf("status: %s\n", resp.Status)
			fmt.Printf("resp header\n")
			for k, v := range resp.Header {
				fmt.Printf("%s: %s\n", k, v)
			}
			fmt.Println("resp body")
			io.Copy(os.Stdout, resp.Body)
			os.Stdout.WriteString("\n")
		}
	}
}

func postForm() {
	//url.Values就是用户提交的表单数据，服务端从body中获取
	if resp, err := http.PostForm("http://127.0.0.1:5656", url.Values{"name": []string{"jack"}, "age": []string{"18"}, "pass": []string{"ljkfldsf"}}); err != nil {
		panic(err)
	} else {
		defer resp.Body.Close()
		fmt.Printf("proto: %s\n", resp.Proto)
		fmt.Printf("status: %s\n", resp.Status)
		fmt.Printf("resp header\n")
		for k, v := range resp.Header {
			fmt.Printf("%s: %s\n", k, v)
		}
		fmt.Println("resp body")
		io.Copy(os.Stdout, resp.Body)
		os.Stdout.WriteString("\n")
	}
}

func main() {
	// get()
	// post()
	// doRequest()
	postForm()
}

```



##### 第三方包 httprouter

* go get -u github.com/julienschmidt/httprouter
* Router实现了http.Handler接口
* 为各种request method提供了便捷的路由方式
* 支持restrul请求方式
* 支持ServeFiles访问静态文件
* 可以自定义捕获panic的方法

go get -u github.com/julienschmidt/httprouter

go run server.go

```go
package main

import (
	"fmt"
	"io"
	"net/http"
	"os"

	"github.com/julienschmidt/httprouter"
)

func getHandler1(w http.ResponseWriter, r *http.Request, params httprouter.Params) {
	fmt.Printf("method: %s\n", r.Method)
	fmt.Printf("request body\n")
	io.Copy(os.Stdout, r.Body)
	fmt.Println()

	w.Write([]byte("hi boy, you request " + r.Method))
}

func getHandler2(w http.ResponseWriter, r *http.Request, params httprouter.Params) {
	fmt.Printf("method: %s\n", r.Method)
	fmt.Printf("request body\n")
	io.Copy(os.Stdout, r.Body)
	fmt.Println()

	var a = 4
	var b = 0
	var _ = a / b
	w.Write([]byte("hi girl, you request " + r.Method))
}

func getHandler3(w http.ResponseWriter, r *http.Request, params httprouter.Params) {
	fmt.Printf("method: %s\n", r.Method)
	fmt.Printf("request body\n")
	io.Copy(os.Stdout, r.Body)
	fmt.Println()

	w.Write([]byte("hi girl，handler func 33333, you request " + r.Method))
}

func postHandler1(w http.ResponseWriter, r *http.Request, params httprouter.Params) {
	fmt.Printf("method: %s\n", r.Method)
	fmt.Printf("request body\n")
	io.Copy(os.Stdout, r.Body)
	fmt.Println()

	w.Write([]byte("hi girl, you request " + r.Method))
}

func postHandler2(w http.ResponseWriter, r *http.Request, params httprouter.Params) {
	fmt.Printf("method: %s\n", r.Method)
	fmt.Printf("request body\n")
	io.Copy(os.Stdout, r.Body)
	fmt.Println()

	w.Write([]byte("hi girl, you request " + r.Method))
}

// HostMap是map类型的别名
type HostMap map[string]http.Handler

// HostMap实现ServerHTTP方法，实现Handler接口
func (hm HostMap) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if handler, exists := hm[r.Host]; exists {
		handler.ServeHTTP(w, r)
	} else {
		http.Error(w, "Forbidden", 403)
	}
}

func main() {
	router := httprouter.New()
	router.GET("/", getHandler1)
	router.GET("/g", getHandler2)

	router.POST("/", postHandler1)
	router.POST("/g", postHandler2)

	// :name :type *addr是变量名称,  例如：/user/jack/vip/sh/xuhui/it  :name=jack, :type=vip *addr=sh/xuhui/it
	router.POST("/user/:name/:type/*addr", func(w http.ResponseWriter, r *http.Request, p httprouter.Params) {
		fmt.Printf("name=%s, type=%s, addre=%s", p.ByName("name"), p.ByName("type"), p.ByName("addr"))
	})

	// router的自定义panic处理函数
	router.PanicHandler = func(w http.ResponseWriter, r *http.Request, i interface{}) {
		fmt.Println("panic happen")
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, "error: %s", i) //i就是panic的原因，写入到响应流中
	}

	//第二个router2
	router2 := httprouter.New()
	router2.GET("/", getHandler3)

	hm := make(HostMap)
	hm["book.dianshang:5656"] = router
	hm["food.dianshang:5656"] = router2

	// router实现了http.Handler
	// http.ListenAndServe(":5656", router)
	// hm也是一个Handler，它实现了ServeHTTP方法
	http.ListenAndServe(":5656", hm)
}
```

go run client.go

```go
package main

import (
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"
)

func get() {
	// if resp, err := http.Get("http://127.0.0.1:5656/g"); err != nil {
	// if resp, err := http.Get("http://book.dianshang:5656/"); err != nil {
	if resp, err := http.Get("http://food.dianshang:5656/"); err != nil {
		panic(err)
	} else {
		//注意一定要调用resp.Body.Close()，否则会协和泄露（同时引发内存泄漏）
		defer resp.Body.Close()
		fmt.Printf("proto: %s\n", resp.Proto)
		fmt.Printf("status: %s\n", resp.Status)
		fmt.Printf("resp header\n")
		for k, v := range resp.Header {
			fmt.Printf("%s: %s\n", k, v)
		}
		fmt.Println("resp body")
		io.Copy(os.Stdout, resp.Body)
		os.Stdout.WriteString("\n")
	}
}

func post() {
	reader := strings.NewReader("hello server")
	if resp, err := http.Post("http://127.0.0.1:5656/user/jack/vip/sh/xuhui/it", "text/plain", reader); err != nil {
		panic(err)
	} else {
		defer resp.Body.Close()
		fmt.Printf("proto: %s\n", resp.Proto)
		fmt.Printf("status: %s\n", resp.Status)
		fmt.Printf("resp header\n")
		for k, v := range resp.Header {
			fmt.Printf("%s: %s\n", k, v)
		}
		fmt.Println("resp body")
		io.Copy(os.Stdout, resp.Body)
		os.Stdout.WriteString("\n")
	}
}

// 自定义请求
func doRequest() {
	reader := strings.NewReader("hello server")
	//可以使用post、get方法请求，get请求时可以传入body，服务端也会获取到
	if req, err := http.NewRequest("get", "http://127.0.0.1:5656", reader); err != nil {
		panic(err)
	} else {
		req.Header.Add("User-Agent", "12345")
		req.Header.Add("key", "golang")
		//定义一个cookie
		req.AddCookie(&http.Cookie{
			Name:   "auth",
			Value:  "here is password",
			Path:   "/",
			Domain: "localhost",
		})

		// 新建客户端，期待客户端500ms拿到响应
		client := http.Client{Timeout: 500 * time.Millisecond}
		// 客户端执行自定义请求
		if resp, err := client.Do(req); err != nil {
			panic(err)
		} else {
			defer resp.Body.Close()
			fmt.Printf("proto: %s\n", resp.Proto)
			fmt.Printf("status: %s\n", resp.Status)
			fmt.Printf("resp header\n")
			for k, v := range resp.Header {
				fmt.Printf("%s: %s\n", k, v)
			}
			fmt.Println("resp body")
			io.Copy(os.Stdout, resp.Body)
			os.Stdout.WriteString("\n")
		}
	}
}

func postForm() {
	//url.Values就是用户提交的表单数据，服务端从body中获取
	if resp, err := http.PostForm("http://127.0.0.1:5656", url.Values{"name": []string{"jack"}, "age": []string{"18"}, "pass": []string{"ljkfldsf"}}); err != nil {
		panic(err)
	} else {
		defer resp.Body.Close()
		fmt.Printf("proto: %s\n", resp.Proto)
		fmt.Printf("status: %s\n", resp.Status)
		fmt.Printf("resp header\n")
		for k, v := range resp.Header {
			fmt.Printf("%s: %s\n", k, v)
		}
		fmt.Println("resp body")
		io.Copy(os.Stdout, resp.Body)
		os.Stdout.WriteString("\n")
	}
}

func main() {
	get()
	// post()
	// doRequest()
	// postForm()
}
```



##### 请求校验



###### XSS

* 跨站脚本攻击Cross-Site Scripting，XSS(为了区别CSS)。通过注入脚本获取敏感信息

```html
<html>
<head>
	<title>留言板</title>
</head>
<body>
	<div id="board">
		<!--从数据库中读出用户的留言内容，展示在这里-->
		<script>alert("hey!you are atacked")</script>
	</div>
</body>
</html>
```



###### CSRF

* Cross-Site request forgery，跨站请求伪造（目前已经禁止跨域读取Cookie，这种方式早已经过时）

1. 登录A网站（银行网站）的个人中心

​	www.bank.com/my.php

2. 登录危险的B网站

​	<img src=http://www.bank.com/Transfer.php?toBacknId=11&money=1000>

​	从B网站向A网站发起了转账请求（携带着A网站的认证Cookie）



###### jsonp

* 主流浏览器不允许跨域访问数据（相同域名不同端口也属于跨域）

* "<script>标签的src属性不受"同源策略"限制，可以进行跨域来满足我们正常的跨域请求"

* 通过script的src请求返回的数据，浏览器会当成js脚本去处理。所以服务端可以返回一个在客户端存在的js函数

  

###### validator

go get github.com/go-playground/validator

```
type RegistRequest struct{
	UserName string `validate: "gt=0"`	//>0 长度大于0
	PassWord string `validate: "min=6 max=12"`	//密码长度[6, 12]
	PassRepeat string `validate: "eqfield=PassWord"`	//跨字段相等校验
	Email string `validate: "email"`	//需要满足email的格式
}
```

范围约束

* 对于字符串、切片、数组和map，约束其长度。len=10，min=6，max=10，gt=10
* 对于数值，约束其取值。min, max, eq, ne, gt, gte, lt, lte, oneof=6 8,

跨字段约束

* 跨字段就在范围约束的基础上加field后缀
  * PassRepeat string `validate: "eqfield=PassWord"`
* 如果还跨结构体(cross struct)就在跨字段的基础上在field前面加cs
  * PassRepeat string `validate: "eqcsfield=Next.Pass"`	//Next是在本结构体中嵌套的结构体

字符串约束

* contains包含子串
* containsany包含任意unicode字符，containsany=abcd
* containsrune包含rune字符，containsrune="笑脸"
* excludes不包含子串
* excludesall不包含任意的unicode字符，excludesall=abcd
* excludesrune不包含rune字符，excludesrune="笑脸"
* startswith以子串为前缀
* endswith以子串为后缀

唯一性uniq

* 对于数组和切片，约束没有重复的元素
* 对于map，约束没有重复的value
* 对于元素类型为结构体的切片，unique约束结构体对象的某个字段不重复，通过unique=field指定这个字段名
  * Friends []Users `validate: "unique=Name"`

自定义约束

```go
func validateEmail(fl validator.FieldLevel) bool{
	input := fl.Field().String()
	if pass,_ := regexp.MatchString(`^([\w\.\_]{2,10})@(\w{1,})\.([a-z]{2,4})$`,input); pass {
	return true
	} 
	return false
}

//注册一个自定义的validator
var val = validator.New()
val.RegisterValidation("my_email",validateEmail )

// 定义结构体字体
Email string `validate: "my_exmil"`	//使用注册的自定义约束my_email，会调用validateEmail进行校验
```

example:

```go
package main

import (
	"fmt"
	"regexp"

	"github.com/go-playground/validator"
)

var val = validator.New()

type RegistRequest struct {
	UserName   string `validate:"gte=5,excludes=小姐"`
	PassWord   string `validate:"min=8,max=20"`
	PassRepeat string `validate:"eqfield=PassWord"`
	Email      string `validate:"my_email_check"`
	Friends    []int  `validate:"unique"`
}

func validateEmail(fl validator.FieldLevel) bool {
	input := fl.Field().String()
	if match, _ := regexp.MatchString(`^([\w\.\_]{2,10})@(\w{1,})\.([a-z]{2,4})$`, input); match {
		return true
	}
	return false
}

func main() {
	val.RegisterValidation("my_email_check", validateEmail)

	request := RegistRequest{
		UserName:   "abc大姐",
		PassWord:   "12345678",
		PassRepeat: "12345678",
		Email:      "abc@qq.com",
		Friends:    []int{1, 2, 3},
	}

	//会校验通过
	if err := val.Struct(request); err != nil {
		fmt.Println(err)
	}

	//会校验不通过
	if err := val.Struct(3); err != nil {
		fmt.Println(err)
	}
}
```



##### 中间件的作用

* 将业务代码和非业务代码解耦
* 非业务代码：限流、超时控制、写日志等



##### 中间件实现的原理

* 传入一个htto.Handler，外面套上一些非业务功能代码，再返回一个http.Handler。
* 支持中间件层层嵌套。通过HandlerFunc把一个func(rw http.ResponseWriter,r *http.Request)函数转为Handler

```go
func timeMiddleWare(next http.Handler) http.Handler {
	return http.HandlerFunc(func(rw http.ResponseWriter, r *http.Request) {
		begin := time.Now()
		next.ServeHTTP(rw, r)
		timeElapsed := time.Since(begin)
		log.Printf("request %s use %d ms\n", r.URL.Path, timeElapsed.Milliseconds())
	})
}
```

example:

```
package main

import (
	"log" //工作当中使用glog
	"net/http"
	"time"
)

func biz1Handler(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("hi boy"))
}

func biz2Handler(w http.ResponseWriter, r *http.Request) {
	time.Sleep(100 * time.Microsecond)
	w.Write([]byte("hi girl"))
}

// 计时中间件，加了时间处理
func timeMiddleWare(next http.Handler) http.Handler {
	f := func(w http.ResponseWriter, r *http.Request) {
		begin := time.Now()
		next.ServeHTTP(w, r)
		timeElapsed := time.Since(begin)
		log.Printf("request %s use %d ns\n", r.URL.Path, timeElapsed.Nanoseconds())
	}
	return http.HandlerFunc(f)
}

// 限流中间件
var limitCh = make(chan struct{}, 100) //管道存放struct，占用内存小，占用1位

func limitMiddleWare(next http.Handler) http.Handler {
	f := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		limitCh <- struct{}{} //往管道放struct{}{}，共100,如果管道此时放第101个strut{}{},则会阻塞无法处理http请求
		log.Printf("cuncurrence %d\n", len(limitCh))
		next.ServeHTTP(w, r)
		<-limitCh

	})
	return http.HandlerFunc(f)
}

type middleware func(http.Handler) http.Handler
// 定义Router结构体实现中间件封装的嵌套
type Router struct {
	middlewareChain []middleware
	mux             map[string]http.Handler //路由
}

// 构造函数，对Router进行初始化
func NewRouter() *Router {
	return &Router{
		middlewareChain: make([]middleware, 0, 10),
		mux:             make(map[string]http.Handler, 10),
	}
}

func (self *Router) Use(m middleware) {
	self.middlewareChain = append(self.middlewareChain, m)
}

func (self *Router) Add(path string, handler http.Handler) {
	var mergedHandler = handler
	for i := 0; i < len(self.middlewareChain); i++ {
		mergedHandler = self.middlewareChain[i](mergedHandler)
	}
	self.mux[path] = mergedHandler
}

func main() {
	// http.Handle("/boy", timeMiddleWare(http.HandlerFunc(biz1Handler))) //biz1Handler函数参数 == http.HandlerFunc的函数参数
	// http.Handle("/girl", limitMiddleWare(http.HandlerFunc(biz2Handler)))

	// http.Handle("/boy", limitMiddleWare(timeMiddleWare(http.HandlerFunc(biz1Handler)))) //biz1Handler函数参数 == http.HandlerFunc的函数参数
	// http.Handle("/girl", timeMiddleWare(limitMiddleWare(http.HandlerFunc(biz2Handler))))

	//由于使用timeMiddleWare(limitMiddleWare(http.HandlerFunc(biz2Handler))))这种方式嵌套中间件，如果中间件大多则太过难懂，自己封装函数实现中间件嵌套
	router := NewRouter()
	router.Use(limitMiddleWare)
	router.Use(timeMiddleWare)
	router.Add("/boy", http.HandlerFunc(biz1Handler))
	router.Add("/girl", http.HandlerFunc(biz2Handler))

	for path, h := range router.mux {
		// fmt.Println(h)
		http.Handle(path, h)
	}

	http.ListenAndServe(":5656", nil)
}

```



##### 打造自己的Web框架

* 框架的作用：节省封装的开发时间，统一各团队的编码风格，节省沟通和排查问题的时间
* Web框架需要具备的功能
  * request参数获取
  * 参数校验。validator
  * 路由。httprouter
  * response生成和渲染
  * 中间件
  * 会话管理



##### Gorilla工具集

* mux
  * 一款强大的HTTP路由和URL匹配器
* websocket
  * 一个快速且被广泛应用的WebSocket实现
* sessions
  * 支持将会话跟踪信息保存到Cookie或文件系统
* handler
  * 为http服务提供很多有用的中间件
* schema
  * 表单数据和go struct互相转换
* csrf
  * 提供防止跨站点请求攻击的中间件







### Go语言http框架使用

1. Gin框架使用
2. Beego框架介绍



#### Gin框架

* Gin是一款高性能的、简单轻巧的http Web框架
* go get -u github.com/gin-gonic/gin
* 学习gin.Context，体会一下go中Context接口的典型实现



##### 路由

* Gin的路由是基于httprouter做的
* 支持GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD
* 支持路由分组，不用重复写上级路径



##### 参数获取

* c.Query() 从GET请求的URL中获取参数
* c.PostForm() 从post表单中获取参数
* c.Param() 从Restful风格的url中获取参数
* c.FormFile() 获取上传的文件，消息类型为form-data
* c.MultipardForm() multipart/form-data可以上传多个form-data 并且用分隔黏土进行分割



##### 参数绑定

```
type Student struct{
	Name String `form:"username" json:"user" uri:"user" xml:"user" yaml:"user" binding:"required"`
	Addr String `form:"addr" json:"addr" uri:"addr" xml:"addr" yaml:"addr" binding:"required"`
}
var stu Student
ctx.ShouldBindJSON(&stu)
```



##### Gin生成response

* c.String() response Context-Type=text/plain
* c.JSON() response.Context-Type=application/json
* c.XML() responnse.Context-Type=application/xml
* c.HTML() 前端写好模板，后端往里面填值
* c.Redirect() 重写向

```go
package main

import (
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
	"github.com/go-playground/validator"
)

func url(engine *gin.Engine) {
	//如果返回html格式信息给客户端，需要先加载
	engine.LoadHTMLFiles("data/home.html")
	// gin框架传入context
	engine.GET("/student", func(c *gin.Context) { //回调函数，请求/student的参数都会被放到gin.Context中
		// name := c.Query("name")
		// addr := c.DefaultQuery("addr", "china")
		//写信息给客户端，响应信息
		// c.String(http.StatusOK, name+" live in "+addr)
		//响应json格式信息给客户端
		// c.JSON(http.StatusOK, gin.H{"name": name, "address": addr})
		//响应html格式信息给客户端，引用加载好的html文件，只需要调用文件名即可
		// c.HTML(http.StatusOK, "home.html", nil)	//nil可以用gin.H{"name": name, "address": addr}，为home.html模板传参
		//重写向请求
		c.Redirect(http.StatusMovedPermanently, "http://127.0.0.1:5656/student/dd/shanghai/xuhui")
	})
}

func post(engine *gin.Engine) {
	engine.POST("/student", func(c *gin.Context) {
		name := c.PostForm("name")
		addr := c.DefaultPostForm("addr", "china") //如果参数不存在将会赋个默认值
		// c.String(http.StatusOK, name+" live in "+addr)
		c.XML(http.StatusOK, gin.H{"name": name, "address": addr})
	})
}

// restful风格接口
func restful(engine *gin.Engine) {
	engine.GET("/student/:name/*addr", func(c *gin.Context) {
		Name := c.Param("name")
		Addr := c.Param("addr")
		c.String(http.StatusOK, Name+" live in "+Addr)
	})
}

func upload_file(engine *gin.Engine) {
	engine.POST("/upload", func(c *gin.Context) {
		file, err := c.FormFile("file") //上传的文件名称
		if err != nil {
			fmt.Println(err)
			c.String(http.StatusInternalServerError, "upload file failed")
		} else {
			c.SaveUploadedFile(file, "./data/"+file.Filename)
			c.String(http.StatusOK, file.Filename)
		}
	})
}

// http请求的参数跟结构体的成员一一对应
type Student struct {
	Name string `form:"username" json:"name" uri:"user" xml:"user" yaml:"user" binding:"required"`
	Addr string `form:"addr" json:"addr" uri:"addr" xml:"addr" yaml:"addr"`
}

// 表单参数绑定
func formBind(engine *gin.Engine) {
	engine.POST("stu/form", func(c *gin.Context) {
		var stu Student
		// 从c中逐一拿出参数跟stu属性一一绑定
		if err := c.ShouldBind(&stu); err == nil {
			fmt.Printf("name=%s, addr=%s\n", stu.Name, stu.Addr)
			c.String(http.StatusOK, stu.Name+" live in "+stu.Addr)
		} else {
			fmt.Println(err)
			c.String(http.StatusInternalServerError, "bind faiiled")
		}
	})
}

// json参数绑定
func jsonBind(engine *gin.Engine) {
	engine.POST("stu/json", func(c *gin.Context) {
		var stu Student
		// 从c中逐一拿出参数跟stu属性一一绑定
		if err := c.ShouldBindJSON(&stu); err == nil {
			fmt.Printf("name=%s, addr=%s\n", stu.Name, stu.Addr)
			c.String(http.StatusOK, stu.Name+" live in "+stu.Addr)
		} else {
			fmt.Println(err)
			c.String(http.StatusInternalServerError, "bind faiiled")
		}
	})
}

func main() {
	//创建引擎
	engine := gin.Default()

	url(engine)
	post(engine)
	restful(engine)
	upload_file(engine)
	formBind(engine)
	jsonBind(engine)

	engine.Run(":5656")
}
```

```html
//home.html
<html>
<head>
	<title>留言板</title>
</head>
<body>
	<div id="board">
		<!--从数据库中读出用户的留言内容，展示在这里-->
		<script>alert("hey!you are atacked")</script>
	</div>
</body>
</html>
```



##### Gin参数检验

* 基于go-playground/validator

```
type Student struct{
	Name string `form:"name" binding:"required"`	//必须上传name参数
	Score int `form:"score" binding:"gt=0"`	//score必须为正数
	Enrollment time.Time `form:"enrollment" binding:"required,before_today" time.format:"2006-01-02 15:04:05" time_utc:"8"`	//入学时间必须早于今天（before_today为自定义约束）,日期格式东8区
	Graduation time.Time `form:"graduation" binding:"required,gtfield=Enrollment" time.format:"2006-01-02" time_utc:"8"`	//毕业时间要晚于入学时间
}
```

example:

```go
type Stu struct {
	Name       string    `form:"name" binding:"required"`                                                                   //必须上传name参数
	Score      int       `form:"score" binding:"gt=0"`                                                                      //score必须为正数
	Enrollment time.Time `form:"enrollment" binding:"required,before_today" time.format:"2006-01-02 15:04:05" time_utc:"8"` //入学时间必须早于今天（before_today为自定义约束）,日期格式东8区
	Graduation time.Time `form:"graduation" binding:"required,gtfield=Enrollment" time.format:"2006-01-02" time_utc:"8"`    //毕业时间要晚于入学时间
}

var beforeToday validator.Func = func(fl validator.FieldLevel) bool {
	if date, ok := fl.Field().Interface().(time.Time); ok {
		now := time.Now()
		if date.Before(now) {
			return true
		} else {
			return false
		}
	}
	return false
}

func main(){
	engine := gin.Default()
	url(engine)
	post(engine)
	restful(engine)
	upload_file(engine)
	formBind(engine)
	jsonBind(engine)
	if v, ok := binding.Validator.Engine().(*validator.Validate); ok {
		v.RegisterValidation("before_today", beforeToday)
	}
	engine.Run(":5656")
}
```



##### Gin中间件

```go
// 定义限流中间件最大并发连接数
var limitCh = make(chan struct{}, 100) //管道存放struct，占用内存小，占用1位，最多并发处理100个请求
// 时间中间件
func timeMiddleWare() gin.HandlerFunc {
	return func(ctx *gin.Context) {
		begin := time.Now()
		ctx.Next() //执行业务逻辑
		timeElapsed := time.Since(begin)
		log.Printf("request %s use %d ns\n", ctx.Request.URL.Path, timeElapsed.Nanoseconds())
	}
}

// 限流中间件
func limitMiddleWare() gin.HandlerFunc {
	return func(ctx *gin.Context) {
		limitCh <- struct{}{} //往管道放struct{}{}，共100,如果管道此时放第101个strut{}{},则会阻塞无法处理http请求
		log.Printf("cuncurrence %d\n", len(limitCh))
		ctx.Next() //执行业务逻辑
		<-limitCh
	}
}

func main() {
	//创建引擎
	engine := gin.Default()

	// url(engine)
	// post(engine)
	// restful(engine)
	// upload_file(engine)
	// formBind(engine)
	// jsonBind(engine)

	// if v, ok := binding.Validator.Engine().(*validator.Validate); ok {
	// 	v.RegisterValidation("before_today", beforeToday)
	// }

	engine.Use(timeMiddleWare()) //全局使用中间件
	engine.GET("/", func(ctx *gin.Context) {
		ctx.String(http.StatusOK, "hi boy")
	})
	engine.GET("girl", limitMiddleWare(), func(ctx *gin.Context) { //局部使用中间件
		ctx.String(http.StatusOK, "hi girl")
	})

	engine.Run(":5656")
}
```



##### Gin会话

* http是无状态的，即服务端不知道两次请求是否来自于同一个客户端
* Cookie由服务端生成，发送给客户端，客户端保存在本地
* 客户端每次发起请求时把Cookie带上，以证明自己的身份
* HTTP请求中的Cookie头只会包含name和value信息（服务端 只能取到name和value），domain、path、expires等cookie属性是由浏览器使用的，对服务器来说没有意义
* Cookie可以被浏览器禁用

examples:

```
//cookie_server.go
package main

import (
	"encoding/base64"
	"fmt"
	"net/http"
	"strconv"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
)

var (
	authMap sync.Map //协程安全的map
)

// cookie name需要符合规则，否则该cookie会被Gin框架默默地丢弃掉
func getCookieName(ctx *gin.Context) string {
	return base64.StdEncoding.EncodeToString([]byte(ctx.Request.RemoteAddr))
}

// 登录
func login(engine *gin.Engine) {
	engine.POST("/login", func(ctx *gin.Context) {
		//为客户端生成cookie
		cookie_key := getCookieName(ctx)
		cookie_value := strconv.Itoa(time.Now().Nanosecond())
		//服务端维护所有客户端的cookie，用于对客户端进行认证
		authMap.Store(cookie_key, cookie_value)
		ctx.SetCookie(cookie_key, cookie_value,
			3000,        //maxAge, cookie的有效时间，单位秒
			"/",         //path, cookie存放目录
			"localhost", //cookie从属的域名
			false,       //是否只能通过https访问
			true,        //是否允许别人通过js获取自己的cookie
		)
		fmt.Printf("set cookie %s = %s to client\n", cookie_key, cookie_value)
		ctx.String(http.StatusOK, "登录成功")
	})
}

// 认证中间件
func authMiddleWare() gin.HandlerFunc {
	return func(ctx *gin.Context) {
		cookie_key := getCookieName(ctx)
		var cookie_value string
		//读取客户端的cookie
		for _, cookie := range ctx.Request.Cookies() {
			if cookie.Name == cookie_key {
				cookie_value = cookie.Value
				break
			}
		}

		//验证Cookie Value是否正确
		if v, ok := authMap.Load(cookie_key); !ok {
			fmt.Printf("INVALID auth cookie %s = %s\n", cookie_key, cookie_value)
			ctx.JSON(http.StatusForbidden, gin.H{cookie_key: cookie_value})
			ctx.Abort() //验证不通过，调用Abort进行中断连接
		} else {
			if v.(string) == cookie_value {
				ctx.Next() //本中间件顺利通过，执行下一步任务
			} else {
				fmt.Printf("INVALID auth cookie %s = %s\n", cookie_key, cookie_value)
				ctx.JSON(http.StatusForbidden, gin.H{cookie_key: cookie_value})
				ctx.Abort() //验证不通过，调用Abort进行中断连接
			}
		}
	}
}

//用户中心
func userCenter(engine *gin.Engine) {
	engine.POST("/center", authMiddleWare(), func(ctx *gin.Context) { //为"/center"加个认证中间件
		ctx.String(http.StatusOK, "您已经通过身份认证，这里是你的私人空间")
	})

	engine.POST("/account", authMiddleWare(), func(ctx *gin.Context) { //为"/account"加个认证中间件
		ctx.String(http.StatusOK, "您已经通过身份认证，这里是你的私人空间")
	})

	engine.POST("/home", func(ctx *gin.Context) {
		ctx.String(http.StatusOK, "您已经通过身份认证，这里是你的私人空间")
	})
}

func main() {
	engine := gin.Default()
	//路由
	login(engine)
	userCenter(engine)

	engine.Run(":5656")
}
```

```
//cookie_client.go
package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
)

func authLogin() {
	if resp, err := http.Post("http://127.0.0.1:5656/login", "text/plain", nil); err != nil {
		panic(err)
	} else {
		fmt.Println("response body")
		io.Copy(os.Stdout, resp.Body)
		os.Stdout.WriteString("\n")
		loginCookies := resp.Cookies()
		resp.Body.Close()
		if req, err := http.NewRequest("POST", "http://127.0.0.1:5656/center", nil); err != nil {
			panic(err)
		} else {
			//下次请求带上cookie
			for _, cookie := range loginCookies {
				fmt.Printf("receive cookie %s = %s\n", cookie.Name, cookie.Value)
				// cookie.Value += "1"
				req.AddCookie(cookie)
			}
			client := &http.Client{}
			if resp, err := client.Do(req); err != nil {
				fmt.Println(err)
			} else {
				defer resp.Body.Close()
				fmt.Println("response body")
				io.Copy(os.Stdout, resp.Body)
				os.Stdout.WriteString("\n")
			}
		}
	}
}

func main() {
	authLogin()
}
```







### Beego

#### 用bee工具创建web项目

```
go get github.com/astaxie/beego
go get github.com/beego/bee
cd $GOPATH/src	//自己存放的项目目录
bee new myweb
cd myweb
go build -mod=mod
bee run
```



#### MVC

* View
  * 前端页面，static下面
* Controller
  * 处理业务逻辑，controllers下面
* Model
  * 把Controller层重复的代码抽象出来，models下面
* 在Model层可以使用beego提供的ORM功能



#### Beego介绍

* beego是一个大而全的http框架，用于快速开发go应用程序。而gin是一个小而美的框架
* bee工具提供诸多命令，帮助我们进行beego项目的创建、热编译、开发、测试和部署
* beego的八大模块互相独立，高度解耦，开发者可任意选取
  * 日志模块
  * ORM模块
  * Context模块。封装了request和response
  * Cache模块。封装了memcache、redis、ssdb
  * Config模块。解析.ini、.yaml、.xml、.json、.env等配置文件
  * httplib模块
  * Session模块。session保存在服务端，用于标识客户身份，跟踪会话
  * toolbox模块。健康检查、性能调试、访问统计、计划任务









## day13(开始项目实战)



### 文件中转站项目

---



课件项目地址：https://gitee.com/infraboard/go-course/   

本天课件地址：https://gitee.com/infraboard/go-course/blob/go7/day08/design.md

自己项目地址：https://github.com/jacknotes/go-share-examples



#### 依赖存储条件

* 需要开通阿里云OSS，用于存储数据

* 在OSS中创建一个Bucket，例如名称叫：devopscloud-station，Bucket ACL为公共读 

* 创建一个子账户，在RAM访问控制中创建，例如：devopscloud-station，并为这个子账户创建AccessKey和Secret

  * AK: LTAI5xyPSts
    SK: Yx14Ls6npgMSAhohVgCb

* 为这个子账户添加授权，授权OSS读写权限，在OSS中找到新建的bucket，权限控制-->Bucket授权管理-->新增授权-->授权用户为子账户，权限为读写权限 

  

#### 简易版文件中转站

大家可能会遇到这种场景:

- 容器里面的日志帮忙拉下来下,我要定位下问题
- 我有一个安装包下载不下来，我需要上传到服务器
- 我有一些比较重要的日志, 需要定期归档到云端, 避免占用本地空间

如何解决这个问题:

- 自己搭建一个文件服务器, 你帮他上传
- 然用户使用系统上的工具自己做一个文件服务器

```
1. nohup python -m SimpleHTTPServer [port] & 快速搭建一个http服务
2. nc ...
```



#### 解决方案

由于可能面临复杂网络下(多层跳板机)的上传和下载问题, 通过点对点传(比如scp之类)的很难行得通，所有选择用中转站的方式，比如oss

oss在产品开发过程中也经常用到比如:

- 用户上传了一个视频，我需要找个地方存储
- 用户上传了一些图片, 我需要找个地方存储

#### 寻找现成工具

我们寻找有没有现有的客户端:

- 阿里有oss browser, cli也可以使用
- 多个云商客户端不能通用

#### 自己做一个简单的工具

1. 查看[阿里云 oss sdk使用样例](https://gitee.com/link?target=https%3A%2F%2Fgithub.com%2Faliyun%2Faliyun-oss-go-sdk)

```
// github.com/aliyun/aliyun-oss-go-sdk/tree/master/oss
client, err := oss.New("Endpoint", "AccessKeyId", "AccessKeySecret")
if err != nil {
    // HandleError(err)
}

bucket, err := client.Bucket("my-bucket")
if err != nil {
    // HandleError(err)
}

err = bucket.PutObjectFromFile("my-object", "LocalFile")
if err != nil {
    // HandleError(err)
}
```



#### 项目代码地址

https://github.com/jacknotes/go-share-examples.git



#### 工具编译

Golang 支持交叉编译，在一个平台上生成另一个平台的可执行程序

![](../image/golang-001.jpg)

```bash
# Windows 下编译 Linux 64位可执行程序
set CGO_ENABLED=0
set GOOS=linux
set GOARCH=amd64
go build main.go

# 编译工具
$ go build -o cloud-station-cli.exe cloud-station/simple/main.go 
```





#### 工程化开发

```
$ cd cloud-station/pro/
$ pwd
/d/share/golang-study/day13-go-share-examples/go-share-examples/cloud-station/pro
$ go mod init "jacknotes/go-share-examples/cloud-station/pro"	//在工程下面新建子工程，父工程为jacknotes/go-share-examples
$ ls
go.mod  main.go
$ code . //在子工程go.mod下打开VScode, 命令为: code .
```



#### 使用VScode单元测试时进行环境注入

1. 点击最左侧栏运行和调试（ctrl + shift + d）--> 创建launch.json文件 --> 选择GO debug默认配置
2. 回到代码界面，此时最顶级将会生成/.vscode/launch.json目录及文件
3. 在/.vscode目录下新建settings.json，并输出如下内容

```
{
    "go.testEnvFile": "${workspaceFolder}/etc/test.env"
}
# 表示环境变量文件在当前工作区下/etc/test.env，/etc是顶级目录,变量参数是key=value
ALI_OSS_ENDPOINT="oss.aliyuncs.com"
ALI_AK="LTAI5tBkStsHx"
ALI_SK="Yx14LsgCbVPF7"
ALI_BUCKET_NAME="devopscloud-station"
```

4. 可以在单元测试中使用fmt.println(ep, ak)进行变量打印，看变量否赋值成功。
5. 在单元测试代码中点击"run test"时，不会默认加上-v参数，为了单元测试详细，需要更改vscode配置，加上-v参数。更改配置方法：左下角设置 --> 设置 --> 用户/工作区 --> 搜索框搜索"test" --> 选择扩展下的GO --> 右边找到GO:test flags --> 点击在settings.json中编辑

![](../image/dev/test01.png)

```
{
    "go.formatTool": "goimports",
    "security.workspace.trust.untrustedFiles": "open",
    "go.toolsManagement.autoUpdate": true,
    "workbench.colorTheme": "Quiet Light",
    "vscodeGoogleTranslate.preferredLanguage": "English",
    "commentTranslate.targetLanguage": "zh-CN",
    "commentTranslate.source": "Bing",
    "go.testFlags": [
      "-v"	//加上-v参数并保存
    ]
}
```

![](../image/dev/test02.png)

注：cached表示是缓存的上次测试，需要再次运行时必需更改代码，哪怕你加个空格保存后，才可以进行当前测试。



#### 客户端接口CLI

借助第三方库，github.com/spf13/cobra



##### 改进敏感信息

借助第三方库，github.com/AlecAivazis/survey



##### 添加进度条

1. 使用oss自带的方法oss.Progress() 并传入ProgressListener对象，

```
type OssProgressListener struct {
}

func NewOssProgressListener() *OssProgressListener {
	return &OssProgressListener{}
}

// OssProgressListener实现ProgressListener接口
func (l *OssProgressListener) ProgressChanged(event *oss.ProgressEvent) {
	// 调试事件返回的信息
	fmt.Println(event)
}

// 
listener := oss.Progress(NewOssProgressListener()) // 传入对象进度条对象，得出Option
err = bucket.PutObjectFromFile(objectKey, fileName, listener) 
```



借助第三方库显示进度条，github.com/schollz/progressbar









## day14(CRUD Demo)

课件项目地址：https://gitee.com/infraboard/go-course/   

本天课件地址：https://gitee.com/infraboard/go-course/blob/go6/day14/demo-api.md

自己项目地址：https://github.com/jacknotes/restful-api-demo



```
/ model.go
package host

import (
	"github.com/go-playground/validator/v10"
)

var (
	validate = validator.New()
)

// 为了后期做资源解锁分两张表存储，<ip> ---> Host, IP, SLB, Redis, Mysql
type Host struct {
	ResourceHash string //         `json:"resource_hash"`
	DescribeHash string //        `json:"describe_hash"`
	*Resource
	*Describe
}

func (h *Host) Validate() error {
	return validate.Struct(h)
}

type Vendor int

const (
	ALI_CLOUD Vendor = iota
	TX_CLOUD
	HW_CLOUD
)

// 主机元数据信息
type Resource struct {
	Id     string `json:"id" validate:"required"`     // 全局唯一Id
	Vendor Vendor `json:"vendor" validate:"required"` // 厂商
	Region string `json:"region" validate:"required"` // 地域
	Zone   string `json:"zone"`                       // 区域
	// 使用的13位时间戳
	// 为什么不用数据库Datetime，如果使用数据库的时间，数据库会默认加上时区
	CreateAt    int64             `json:"create_at" validate:"required"`  // 创建时间
	ExpireAt    int64             `json:"expire_at"`                      // 过期时间
	Category    string            `json:"category"`                       // 种类
	Type        string            `json:"type"`                           // 规格
	InstanceId  string            `json:"instance_id"`                    // 实例ID
	Name        string            `json:"name" validate:"required"`       // 名称
	Description string            `json:"description"`                    // 描述
	Status      string            `json:"status" validate:"required"`     // 服务商中的状态
	Tags        map[string]string `json:"tags"`                           // 标签
	UpdateAt    int64             `json:"update_at"`                      // 更新时间
	SyncAt      int64             `json:"sync_at"`                        // 同步时间
	SyncAccount string            `json:"sync_accout"`                    // 同步的账号
	PublicIP    string            `json:"public_ip"`                      // 公网IP
	PrivateIP   string            `json:"private_ip" validate:"required"` // 内网IP
	PayType     string            `json:"pay_type"`                       // 实例付费方式
}

type Describe struct {
	CPU                     int    `json:"cpu" validate:"required"`    // 核数
	Memory                  int    `json:"memory" validate:"required"` // 内存
	GPUAmount               int    `json:"gpu_amount"`                 // GPU数量
	GPUSpec                 string `json:"gpu_spec"`                   // GPU类型
	OSType                  string `json:"os_type"`                    // 操作系统类型，分为Windows和Linux
	OSName                  string `json:"os_name"`                    // 操作系统名称
	SerialNumber            string `json:"serial_number"`              // 序列号
	ImageID                 string `json:"image_id"`                   // 镜像ID
	InternetMaxBandwidthOut int    `json:"internet_max_bandwidth_out"` // 公网出带宽最大值，单位为 Mbps
	InternetMaxBandwidthIn  int    `json:"internet_max_bandwidth_in"`  // 公网入带宽最大值，单位为 Mbps
	KeyPairName             string `json:"key_pair_name"`              // 秘钥对名称
	SecurityGroups          string `json:"security_groups"`            // 安全组  采用逗号分隔
}

// 查询主机列表信息 返回参数
type Set struct {
	Total int64
	Items []*Host
}
```







### mysql数据库建表

```
// resource
CREATE TABLE `resource` (
  `id` char(64) CHARACTER SET latin1 NOT NULL,
  `vendor` tinyint(1) NOT NULL,
  `region` varchar(64) CHARACTER SET latin1 NOT NULL,
  `zone` varchar(64) CHARACTER SET latin1 NOT NULL,
  `create_at` bigint(13) NOT NULL,
  `expire_at` bigint(13) NOT NULL,
  `category` varchar(64) CHARACTER SET latin1 NOT NULL,
  `type` varchar(120) CHARACTER SET latin1 NOT NULL,
  `instance_id` varchar(120) CHARACTER SET latin1 NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `status` varchar(255) CHARACTER SET latin1 NOT NULL,
  `update_at` bigint(13) NOT NULL,
  `sync_at` bigint(13) NOT NULL,
  `sync_accout` varchar(255) CHARACTER SET latin1 NOT NULL,
  `public_ip` varchar(64) CHARACTER SET latin1 NOT NULL,
  `private_ip` varchar(64) CHARACTER SET latin1 NOT NULL,
  `pay_type` varchar(255) CHARACTER SET latin1 NOT NULL,
  `describe_hash` varchar(255) NOT NULL,
  `resource_hash` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `name` (`name`) USING BTREE,
  KEY `status` (`status`) USING HASH,
  KEY `private_ip` (`public_ip`) USING BTREE,
  KEY `public_ip` (`public_ip`) USING BTREE,
  KEY `instance_id` (`instance_id`) USING HASH
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4


// host
CREATE TABLE `host` (
  `resource_id` varchar(64) NOT NULL,
  `cpu` tinyint(4) NOT NULL,
  `memory` int(13) NOT NULL,
  `gpu_amount` tinyint(4) NOT NULL,
  `gpu_spec` varchar(255) NOT NULL,
  `os_type` varchar(255) NOT NULL,
  `os_name` varchar(255) NOT NULL,
  `serial_number` varchar(120) NOT NULL,
  `image_id` char(64) NOT NULL,
  `internet_max_bandwidth_out` int(10) NOT NULL,
  `internet_max_bandwidth_in` int(10) NOT NULL,
  `key_pair_name` varchar(255) NOT NULL,
  `security_groups` varchar(255) NOT NULL,
  PRIMARY KEY (`resource_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
```

#### navicat语句测试

```
INSERT INTO resource (
		id,vendor,region,zone,create_at,expire_at,category,type,instance_id,
		name,description,status,update_at,sync_at,sync_accout,public_ip,
		private_ip,pay_type,resource_hash,describe_hash
	) VALUES ("001","0","hd2","sh","20221204","20231204","cat","t","in","name","des","st","20221206","20221206","test","223.6.6.6","10.10.10.1","yf","123","deshash");
	
select * from resource;
```



### HTTP API暴露

我们服务核心逻辑已经编码完成, 剩下得就是通过我们想要的协议暴露给用户使用, 我们通过HTTP协议暴力, API以[RestFull风格来设计](https://gitee.com/link?target=http%3A%2F%2Fwww.nbtuan.vip%2F2017%2F10%2F03%2Frestful-vs-soap%2F)





### 组装功能，实现启动入口

为程序提供cli启动命令, 类似于

```
demo-api start
```

服务启动流程大致如下:

- 读取配置, 初始化全局变量
- 初始化全局日志配置, 加载全局日志实例
- 初始化服务层, 将我们的服务实例注册到 Ioc
- 创建服务, 监听中断信号
- 启动服务









## day15(从RPC到GRPC)



###  编译优化

正常情况下我们这样编译我们的程序

```
$ go build -o demo-api main.go
```

打包出来的程序有13M的样子, 如果想要编译的产物变小可以 通过编译进行一些优化:

通过ldflags可以传递一些参数，控制编译的过程

- -s 的作用是去掉符号信息。去掉符号表，golang panic 时 stack trace 就看不到文件名及出错行号信息了。
- -w 的作用是去掉 DWARF tables 调试信息。结果就是得到的程序就不能用 gdb 调试了

```
go build -ldflags "-s -w" -o demo-api main.go
```

产物从 13M --> 11M, 如果你程序越来越复杂，产物越大, 优化后还是很可观的



###  工程化

刚开始我们这样run和build

```
go run main.go -f etc/demo-api.toml start
go build -ldflags "-s -w" -o demo-api main.go	//
```

但是虽然你工程越来越复杂, 需要的周边工具和脚本会越来越多, 比如:

- 代码风格检查
- 覆盖率测试
- 静态检查
- ...

因此我们需要引入Makefile来管理我们的工程



### Makefile

#### 安装make

macOS/Linux的同学 直接用包管理工具安装就可以了, windows的同学请参考:

1. 下载 mingw-get-setup.exe 包（[链接）](https://osdn.net/projects/mingw/)
2. 执行.\mingw-get-setup.exe install mingw32-make(需要用上 墙 才能下载)
3. 最后重命名 mingw32-make.exe为make.exe即可

#### 编写Makefile

我们把常用的功能添加成make指令如下:

```
PROJECT_NAME=restful-api-demo
MAIN_FILE=main.go
PKG := "github.com/jacknotes/$(PROJECT_NAME)"
PKG_LIST := $(shell go list ${PKG}/... | grep -v /vendor/)
GO_FILES := $(shell find . -name '*.go' | grep -v /vendor/ | grep -v _test.go)
PKG_CONFIG := "etc/restful-api.toml"

.PHONY: all dep lint vet test test-coverage build clean

all: build

dep: ## Get the dependencies
	@go mod tidy

lint: ## Lint Golang files
	@golint -set_exit_status ${PKG_LIST}

vet: ## Run go vet
	@go vet ${PKG_LIST}

test: ## Run unittests
	@go test -short ${PKG_LIST}

test-coverage: ## Run tests with coverage
	@go test -short -coverprofile cover.out -covermode=atomic ${PKG_LIST} 
	@cat cover.out >> coverage.txt

build: dep ## Build the binary file
	@go build -ldflags "-s -w" -o dist/${PROJECT_NAME} $(MAIN_FILE)

linux: dep ## Build the binary file
	@GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -o ${PROJECT_NAME} $(MAIN_FILE)

windows: dep ## Build the binary file
	@GOOS=windows GOARCH=amd64 go build -ldflags "-s -w" -o ${PROJECT_NAME} $(MAIN_FILE)

mac: dep ## Build the binary file
	@GOOS=darwin GOARCH=amd64 go build -ldflags "-s -w" -o ${PROJECT_NAME} $(MAIN_FILE)

freeBSD: dep ## Build the binary file
	@GOOS=freebsd GOARCH=amd64 go build -ldflags "-s -w" -o ${PROJECT_NAME} $(MAIN_FILE)

run: ## Run Develop server
	@go run $(MAIN_FILE) start -f ${PKG_CONFIG}

clean: ## Remove previous build
	@rm -f dist/*
	@ rm -f cover.out coverage.txt 

push: # push git to multi repo
	@git push

help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

```



### RPC

rpc服务最多的优点就是 我们可以像使用本地函数一样使用 远程服务上的函数, 因此有几个关键点:

- 远程连接: 类似于我们的pkg
- 函数名称: 要表示的函数名称
- 函数参数: 这个需要符合RPC服务的调用签名, 及第一个参数是请求，第二个参数是响应
- 函数返回: rpc函数的返回是 连接异常信息, 真正的业务Response不能作为返回值

```go
// service
package service

const (
	Name = "HelloService"
)

type Service interface {
	Hello(name string, response *string) error
}
----
// server
package main

import (
	"fmt"
	"net"
	"net/rpc"

	"github.com/jacknotes/grpc-demo/rpc/service"
)

// var _ Service = &HelloService{}
// 我们声明了一个空指针，强制把这个指针转换成了一个*HelloService类型
// var _ service.Service = (*HelloService)(nil)

type HelloService struct{}

// 业务场景
// 该函数需要被客户端调用
// 改造成符合rpc规范的 函数签名
// 1. 第一个参数request, interface{}类型
// 2. 第二个参数是一个响应response,interface{}类型，必须是一个指针，需要回写到response
// 3. 返回一个error，不过一般我们通过response进行返回错误信息
func (s *HelloService) Hello(name string, response *string) error {
	*response = fmt.Sprintf("Hello, %s", name)
	return nil
}

func main() {
	// 把要提供的服务注册给RPC框架
	err := rpc.RegisterName(service.Name, new(HelloService))
	if err != nil {
		panic(err)
	}

	// 监听Socket
	listener, err := net.Listen("tcp", ":1234")
	if err != nil {
		panic(err)
	}
	for {
		conn, err := listener.Accept()
		if err != nil {
			panic(err)
		}

		// 前面都是tcp的知识，到这里RPC就接管了
		// 因此，你可以认为RPC帮我们封装消息到函数调用的这个逻辑，
		// 提升了工作效率，逻辑比较简洁，可以看看相关代码
		go rpc.ServeConn(conn)
	}
}
----
// client
package main

import (
	"fmt"
	"net/rpc"

	"github.com/jacknotes/grpc-demo/rpc/service"
)

// 我们声明了一个空指针，强制把这个指针转换成了一个*HelloServiceClient类型
// var _ service.Service = (*HelloServiceClient)(nil)

type HelloServiceClient struct {
	client *rpc.Client
}

// 客户端构建函数
func NewHelloServiceClient(network, address string) (service.Service, error) {
	// 首先是通过rpc.Dial拨号RPC服务, 建立连接
	client, err := rpc.Dial(network, address)
	if err != nil {
		return nil, err
	}

	return &HelloServiceClient{
		client: client,
	}, nil
}

// 对于RPC客户端来说，我们就需要包装客户端的调用
func (c *HelloServiceClient) Hello(name string, response *string) error {
	// 然后通过client.Call调用具体的RPC方法
	// 在调用client.Call时:
	// 		第一个参数是用点号链接的RPC服务名字和对象的方法名字，
	// 		第二个参数是 请求参数
	//      第三个是请求响应, 必须是一个指针, 有底层rpc服务帮你赋值
	return c.client.Call(service.Name+".Hello", name, response)
}

func main() {
	client, err := NewHelloServiceClient("tcp", "127.0.0.1:1234")
	if err != nil {
		panic(err)
	}
	var response string
	client.Hello("World", &response)
	fmt.Println(response)
}
```



### gob编码(go binary)

* 标准库的RPC默认采用Go语言特有的gob编码, 标准库gob是golang提供的“私有”的编解码方式，它的效率会比json，xml等更高，特别适合在Go语言程序间传递数据

* gob的使用很简单, 和之前使用base64编码理念一样, 有 Encoder和Decoder



### Json ON TCP

gob是golang提供的“私有”的编解码方式，因此从其它语言调用Go语言实现的RPC服务将比较困难

因此我们可以选用所有语言都支持的比较好的一些编码:

- MessagePack: 高效的二进制序列化格式。它允许你在多种语言(如JSON)之间交换数据。但它更快更小
- JSON: 文本编码
- XML：文本编码
- Protobuf 二进制编码

Go语言的RPC框架有两个比较有特色的设计：

- RPC数据打包时可以通过插件实现自定义的编码和解码；
- RPC建立在抽象的io.ReadWriteCloser接口之上的，我们可以将RPC架设在不同的通讯协议之上。

这里我们将尝试通过官方自带的net/rpc/jsonrpc扩展实现一个跨语言的RPC。

```go
// server
func main() {
	// 把要提供的服务注册给RPC框架
	err := rpc.RegisterName(service.Name, new(HelloService))
	if err != nil {
		panic(err)
	}

	// 监听Socket
	listener, err := net.Listen("tcp", ":1234")
	if err != nil {
		panic(err)
	}
	for {
		conn, err := listener.Accept()
		if err != nil {
			panic(err)
		}

		// 前面都是tcp的知识，到这里RPC就接管了,默认是gob类型的rpc
		// 因此，你可以认为RPC帮我们封装消息到函数调用的这个逻辑，
		// 提升了工作效率，逻辑比较简洁，可以看看相关代码
		// go rpc.ServeConn(conn)

		// json on tcp 类型的rpc
		go rpc.ServeCodec(jsonrpc.NewServerCodec(conn))
	}
}
----

// client
func NewHelloServiceClient(network, address string) (service.Service, error) {
	// 首先是通过rpc.Dial拨号RPC服务, 建立连接
	conn, err := net.Dial(network, address)
	if err != nil {
		return nil, err
	}

	// 客户端实现了基于JSON的编解码
	client := rpc.NewClientWithCodec(jsonrpc.NewClientCodec(conn))

	return &HelloServiceClient{
		client: client,
	}, nil
}
```

验证功能是否正常

由于没有合适的tcp工具, 比如nc, 同学可以下来自己验证

```bash
$ echo -e '{"method":"HelloService.Hello","params":["hello"],"id":1}' | nc localhost 1234
{"id":1,"result":"hello:hello","error":null}
```



### Json ON HTTP

Go语言内在的RPC框架已经支持在Http协议上提供RPC服务, 为了支持跨语言，编码我们依然使用Json

新的RPC服务其实是一个类似REST规范的接口，接收请求并采用相应处理流程

首先我们依然要解决JSON编解码的问题, 我们需要将HTTP接口的Handler参数传递给jsonrpc, 因此需要满足jsonrpc接口, 因此我们需要提前构建也给conn io.ReadWriteCloser, writer现成的 reader就是request的body, 直接内嵌就可以

```
func NewRPCReadWriteCloserFromHTTP(w http.ResponseWriter, r *http.Request) *RPCReadWriteCloser {
	return &RPCReadWriteCloser{w, r.Body}
}

type RPCReadWriteCloser struct {
	io.Writer
	io.ReadCloser
}
```

服务端:

```
func main() {
	rpc.RegisterName("HelloService", new(HelloService))

	// RPC的服务架设在“/jsonrpc”路径，
	// 在处理函数中基于http.ResponseWriter和http.Request类型的参数构造一个io.ReadWriteCloser类型的conn通道。
	// 然后基于conn构建针对服务端的json编码解码器。
	// 最后通过rpc.ServeRequest函数为每次请求处理一次RPC方法调用
	http.HandleFunc("/jsonrpc", func(w http.ResponseWriter, r *http.Request) {
		conn := NewRPCReadWriteCloserFromHTTP(w, r)
		rpc.ServeRequest(jsonrpc.NewServerCodec(conn))
	})

	http.ListenAndServe(":1234", nil)
}
```

![rpc-json-on-http](..\image\golang\rpc-json-on-http01.png)

注： 这种用法常见于你的rpc服务需要暴露多种协议的时候, 其他时候还是老老实实写Restful API









### protobuf(Protocol Buffers)编解码

Protobuf是Protocol Buffers的简称，它是Google公司开发的一种数据描述语言，并于2008年对外开源。Protobuf刚开源时的定位类似于XML、JSON等数据描述语言，通过附带工具生成代码并实现将结构化数据序列化的功能。但是我们更关注的是Protobuf作为接口规范的描述语言，可以作为设计安全的跨语言PRC接口的基础工具



#### 为什么选择Protobuf

一般而言我们需要一种编解码工具会参考:

- 编解码效率
- 高压缩比
- 多语言支持

之前我们的RPC要么使用的Gob, 要么使用的json, 接下来我们将使用probuf

首先创建hello.proto文件，其中包装HelloService服务中用到的字符串类型

```protobuf
syntax = "proto3";

package hello;
option go_package="github.com/jacknotes/grpc-demo/protobuf";    // go mod名称加protobuf路径，生成到这里面来

message String {
    string value = 1;
}
```

- syntax: 表示采用proto3的语法。第三版的Protobuf对语言进行了提炼简化，所有成员均采用类似Go语言中的零值初始化（不再支持自定义默认值），因此消息成员也不再需要支持required特性。
- package：指明当前是main包（这样可以和Go的包名保持一致，简化例子代码），当然用户也可以针对不同的语言定制对应的包路径和名称。
- option：protobuf的一些选项参数, 这里指定的是要生成的Go语言package路径, 其他语言参数各不相同
- message: 关键字定义一个新的String类型，在最终生成的Go语言代码中对应一个String结构体。String类型中只有一个字符串类型的value成员，该成员编码时用1编号代替名字

关于数据编码:

```
在XML或JSON等数据描述语言中，一般通过成员的名字来绑定对应的数据。但是Protobuf编码却是通过成员的唯一编号来绑定对应的数据，因此Protobuf编码后数据的体积会比较小，但是也非常不便于人类查阅。我们目前并不关注Protobuf的编码技术，最终生成的Go结构体可以自由采用JSON或gob等编码格式，因此大家可以暂时忽略Protobuf的成员编码部分
```

但是我们如何把这个定义文件(IDL: 接口描述语言), 编译成不同语言的数据结构喃? 着就需要我们安装protobuf的编译器



#### 安装编译器

protobuf的编译器叫: protoc(protobuf compiler), 我们需要到这里下载编译器: [Github Protobuf](https://github.com/protocolbuffers/protobuf/releases/download/v3.19.6/protoc-3.19.6-win64.zip)

这个压缩包里面有:

- include, 头文件或者库文件
- bin, protoc编译器，将protoc执行文件放到path路径下
- readme.txt, 一定要看，按照这个来进行安装

#### 安装编译器库

include 下的库文件需要安装到: /usr/local/include/

linux/unix系统直接:

```
mv include/google /usr/local/include
```

windows系统:

```
1. 将"D:\Program Files (x86)\protoc\bin\protoc.exe"路径放到Path变量中

2. $ where git	#查找git安装目录，可以看出安装目录为C:\Program Files\Git\
C:\Program Files\Git\mingw64\bin\git.exe
C:\Program Files\Git\cmd\git.exe

3. C:\Program Files\Git\usr\local\include	#在C:\Program Files\Git\下需要创建子目录

4. 复制"D:\Program Files (x86)\protoc\include\google"到"C:\Program Files\Git\usr\local\include"中
```

#### 验证安装

```
$ protoc --version
libprotoc 3.19.6
```

#### 安装Go语言插件

Protobuf核心的工具集是C++语言开发的，在官方的protoc编译器中并不支持Go语言。要想基于上面的hello.proto文件生成相应的Go代码，需要安装相应的插件

```
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
```

接下来 我们就可以使用protoc 来生成我们对于的Go语言的数据结构

#### 编译proto文件

- -I：-IPATH, --proto_path=PATH, 指定proto文件搜索的路径, 如果有多个路径 可以多次使用-I 来指定, 如果不指定默认为当前目录
- --go_out: --go指插件的名称, 我们安装的插件为: protoc-gen-go, 而protoc-gen是插件命名规范, go是插件名称, 因此这里是--go, 而--go_out 表示的是 go插件的 out参数, 这里指编译产物的存放目录
- --go_opt: protoc-gen-go插件opt参数, 这里的module指定了go module, 生成的go pkg 会去除掉module路径，生成对应pkg
- pb/hello.proto: 我们proto文件路径

```
syntax = "proto3";

package hello;
option go_package="github.com/jacknotes/grpc-demo/protobuf";    // go mod名称加protobuf路径，生成到这里面来

message String {
    string value = 1;
}
```

```
$ pwd
/d/share/golang-study/day15-grpc-demo/grpc-demo/protobuf


$ protoc -I=. --go_out=. --go_opt=module="github.com/jacknotes/grpc-demo/protobuf" hello.proto 	// --go_opt=module="github.com/jacknotes/grpc-demo/protobuf"意为忽略此前缀，否则会在当前目录下自己添加层级目录

$ ll
total 5
-rw-r--r-- 1 jack 197121 4077 12月 12 21:24 hello.pb.go	#生成的protobuf文件
-rw-r--r-- 1 jack 197121  204 12月 12 20:46 hello.proto

$ go mod tidy
go: finding module for package google.golang.org/protobuf/runtime/protoimpl
go: finding module for package google.golang.org/protobuf/reflect/protoreflect
go: found google.golang.org/protobuf/reflect/protoreflect in google.golang.org/protobuf v1.28.1
go: found google.golang.org/protobuf/runtime/protoimpl in google.golang.org/protobuf v1.28.1

```

注：团队开发一定要保证各方版本一致，否则会导致重新编译、覆盖等麻烦，此后就可以直接引用protobuf.String了

protoc-gen-go v1.28.1、 protoc  v3.19.6





### protobuf on TCP

[参考链接]([day15/protobuf.md · infraboard/go-course - 码云 - 开源中国 (gitee.com)](https://gitee.com/infraboard/go-course/blob/master/day15/protobuf.md))







## day16



### proto3语法入门

[链接][day15/proto3_synx.md · infraboard/go-course - 码云 - 开源中国 (gitee.com)](https://gitee.com/infraboard/go-course/blob/master/day15/proto3_synx.md#any)



### protobuf example

```
syntax = "proto3";

package grpc.demo.hello;
option go_package="github.com/jacknotes/grpc-demo/protobuf";    // go mod名称加protobuf路径，生成到这里面来


// 这里是应用其他的proto文件, 后面会讲 ipmort用法
import "google/protobuf/any.proto";

message Response {
  int32 code = 1;
  google.protobuf.Any data = 2;
}


message String {
    string value = 1;       // 等价于Value string中go变量的写法，probobuf字段默认大写，为全部导出，不可配置为小写
    optional string key = 2;    // Key string , 为入optional后运行为nil "" null
    optional bool enabled = 3;  // 默认enabled=false,  添加了optional则默认是nil了，enabled != nil 时才添加过滤条件
    double metric_value = 4;    // float64，会默认把蛇形转换为大驼峰形

    map<string,int32> values = 5;  //map<string,string> 为key和value的类型

    String1 string1 = 6; // 结构体嵌套
}

message String1 {
    reserved 4,6 to 10;     //保留编号，后面不允许使用
    string value = 1;       // 等价于Value string中go变量的写法，probobuf字段默认大写，为全部导出，不可配置为小写
    optional string key = 2;    // Key string , 添加了optional则默认是nil了，为入optional后运行为nil "" null
    optional bool enabled = 3;  // 默认enabled=false,  enabled != nil 时才添加过滤条件

    repeated Option option = 5; // Option的数组
}

// 定义枚举类型
enum Option {
    // 允许别名
    option allow_alias = true;
    // 枚举选项, 必须从0编号开始，0编号标识的是枚举的默认值
    A = 0;      // A后面版本会弃用
    B = 1;
    C = 2;
    D = 0;      // D默认不能定义0编号，但是需要跟A编号一样，则需要开启允许别名
}


message Sub1 {
    string name = 1;
}

message Sub2 {
    string name = 1;
}

message SampleMessage {
    oneof test_one_of {
        Sub1 sub1 = 1;
        Sub2 sub2 = 2;
    }
}
---
syntax = "proto3";

package grpc.demo.pkg;
option go_package="github.com/jacknotes/grpc-demo/protobuf";    // go mod名称加protobuf路径，生成到这里面来

// 导入包grpc.demo.hello，根据执行位置而定
import "protobuf/hello.proto";


message Pkg1 {
    grpc.demo.hello.Response response = 1;
}

---
// main.go 
package main

import (
	"fmt"

	"github.com/jacknotes/grpc-demo/protobuf"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/anypb"
)

func main() {
	s1 := &protobuf.String{
		Value: "number 1中文",
	}

	payload, err := proto.Marshal(s1)
	if err != nil {
		panic(err)
	}

	fmt.Println(payload)
	// fmt.Println(string(payload))

	s2 := &protobuf.String{}
	proto.Unmarshal(payload, s2)
	fmt.Println(s2)

	// Oneof 使用
	sm := &protobuf.SampleMessage{
		TestOneOf: &protobuf.SampleMessage_Sub2{
			Sub2: &protobuf.Sub2{Name: "test"},
		},
	}
	fmt.Println(sm.GetSub1()) // <nil>
	fmt.Println(sm.GetSub2()) // name:"test"

	// any 使用
	// 把sub2转化为any类型
	sub2, _ := anypb.New(&protobuf.Sub2{Name: "test"})
	resp := &protobuf.Response{
		Code: 0,
		Data: sub2,
	}
	fmt.Println(resp)

	sub3 := &protobuf.Sub2{}
	sub2.UnmarshalTo(sub3)
	fmt.Println(sub3)
}
```



```
// README.md
$ ls /c/Program\ Files/Git/usr/local/include/google/protobuf/
any.proto  compiler/         duration.proto  field_mask.proto      struct.proto     type.proto
api.proto  descriptor.proto  empty.proto     source_context.proto  timestamp.proto  wrappers.proto

$ protoc -I=. -I='/c/Program Files/Git/usr/local/include' --go_out=./protobuf/ --go_opt=module="github.com/jacknotes/grpc-demo/protobuf" .
/protobuf/hello.proto
```



### GRPC入门

```protobuf
// hello.proto
syntax = "proto3";

package grpc.demo.protocol;
option go_package="github.com/jacknotes/grpc-demo/grpc/protocol";    // go mod名称加protobuf路径，生成到这里面来

// grpc 需要定义rpc， 需要安装插件，才能让protobuf生成grpc代码
// 安装protoc-gen-go-grpc插件 go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
service HelloService {
    // Hello rpc函数的名称
    // Request rpc函数的参数
    // Response rpc函数的返回参数
    rpc Hello(Request) returns (Response);
}

message Request {
    string value = 1;
}

message Response {
    string value = 1;
}

```

```
# 安装protoc-gen-go-grpc插件，从protobuf编译生成grpc相关代码
$ go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1.0
$ protoc-gen-go-grpc.exe --version
protoc-gen-go-grpc 1.1.0

# 进入protocol目录
cd protocol

# 生成grpc 和 protobuf编译文件, 需要加入 --go-grpc_out和--go-grpc_opt参数
protoc -I=. -I='/c/Program Files/Git/usr/local/include' --go_out=. --go-grpc_out=.  --go_opt=module="github.com/jacknotes/grpc-demo/grpc/protocol" --go-grpc_opt=module="github.com/jacknotes/grpc-demo/grpc/protocol" hello.proto
```

```go
// hello grpc server.go
package main

import (
	"context"
	"fmt"
	"net"

	"github.com/jacknotes/grpc-demo/grpc/protocol"
	"google.golang.org/grpc"
)

type Service struct {
	// 结构体嵌套(必须是匿名)，等价于继承UnimplementedHelloServiceServer，而UnimplementedHelloServiceServer实现了
	// HelloServiceServer接口，所以Service间接实现了HelloServiceServer接口
	protocol.UnimplementedHelloServiceServer
}

// 重写protocol.UnimplementedHelloServiceServer的方法Hello,简单加个hello前缀
func (s *Service) Hello(ctx context.Context, req *protocol.Request) (*protocol.Response, error) {
	return &protocol.Response{
		Value: "hello: " + req.Value,
	}, nil
}

func main() {
	// 如何把Service 作为一个rpc暴露出去，提供服务
	server := grpc.NewServer()

	// Service生成的代码里面，提供了注册函数，把自己注册到grpc的servr内
	protocol.RegisterHelloServiceServer(server, new(Service))

	// 开启grpc服务
	ls, err := net.Listen("tcp", ":1234")
	if err != nil {
		panic(err)
	}
	// 监听grpc服务
	if err := server.Serve(ls); err != nil {
		fmt.Println(err)
	}
}
---
// hello grpc client.go
package main

import (
	"context"
	"fmt"

	"github.com/jacknotes/grpc-demo/grpc/protocol"
	"google.golang.org/grpc"
)

func main() {
	// grpc.WithInsecure()表示不使用tls
	conn, err := grpc.Dial("127.0.0.1:1234", grpc.WithInsecure())
	if err != nil {
		panic(err)
	}

	client := protocol.NewHelloServiceClient(conn)
	// context.Background()放在后台一直跑，相当于root的上下文
	resp, err := client.Hello(context.Background(), &protocol.Request{Value: "jack"})
	if err != nil {
		panic(err)
	}
	fmt.Println(resp)
}
```



#### gRPC流

```protobuf
syntax = "proto3";

package grpc.demo.protocol;
option go_package="github.com/jacknotes/grpc-demo/grpc/protocol";    // go mod名称加protobuf路径，生成到这里面来

// grpc 需要定义rpc， 需要安装插件，才能让protobuf生成grpc代码
// 安装protoc-gen-go-grpc插件 go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
service HelloService {
    // Hello rpc函数的名称
    // Request rpc函数的参数
    // Response rpc函数的返回参数
    rpc Hello(Request) returns (Response);

    // stream rpc， 双向流
    rpc Chat(stream Request) returns (stream Response);
}

message Request {
    string value = 1;
}

message Response {
    string value = 1;
}
```

```
# 进入protocol目录
cd protocol

# 生成grpc 和 protobuf编译文件, 指定protobuf文件的搜索位置为当前目录 -I=.
protoc -I=. -I='/c/Program Files/Git/usr/local/include' --go_out=. --go-grpc_out=.  --go_opt=module="github.com/jacknotes/grpc-demo/grpc/protocol" --go-grpc_opt=module="github.com/jacknotes/grpc-demo/grpc/protocol" hello.proto
```

```go
// server.go
package main

import (
	"context"
	"fmt"
	"io"
	"net"

	"github.com/jacknotes/grpc-demo/grpc/protocol"
	"google.golang.org/grpc"
)

type Service struct {
	// 结构体嵌套(必须是匿名)，等价于继承UnimplementedHelloServiceServer，而UnimplementedHelloServiceServer实现了
	// HelloServiceServer接口，所以Service间接实现了HelloServiceServer接口
	protocol.UnimplementedHelloServiceServer
}

// 重写protocol.UnimplementedHelloServiceServer的方法Hello,简单加个hello前缀
func (s *Service) Hello(ctx context.Context, req *protocol.Request) (*protocol.Response, error) {
	return &protocol.Response{
		Value: "hello: " + req.Value,
	}, nil
}

// server --> stream --> client
// 重写，HelloService_ChatServer 对应 HelloService_ChatClient
func (s *Service) Chat(stream protocol.HelloService_ChatServer) error {
	// 可以把stream当成一个channel io pipe对象
	for {
		// 接收客户端请求
		req, err := stream.Recv()
		if err != nil {
			if err == io.EOF {
				fmt.Println("chat exit")
				return nil
			}
			fmt.Println(err)
			return err
		}
		// 处理请求
		err = stream.Send(&protocol.Response{Value: "hello: " + req.Value})
		if err != nil {
			fmt.Println(err)
			return err
		}
	}
}

func main() {
	// 如何把Service 作为一个rpc暴露出去，提供服务
	server := grpc.NewServer()

	// Service生成的代码里面，提供了注册函数，把自己注册到grpc的servr内
	protocol.RegisterHelloServiceServer(server, new(Service))

	// 开启grpc服务
	ls, err := net.Listen("tcp", ":1234")
	if err != nil {
		panic(err)
	}
	// 监听grpc服务
	if err := server.Serve(ls); err != nil {
		fmt.Println(err)
	}
}
---
// client.go
package main

import (
	"context"
	"fmt"
	"time"

	"github.com/jacknotes/grpc-demo/grpc/protocol"
	"google.golang.org/grpc"
)

func main() {
	// grpc.WithInsecure()表示不使用tls
	conn, err := grpc.Dial("127.0.0.1:1234", grpc.WithInsecure())
	if err != nil {
		panic(err)
	}

	client := protocol.NewHelloServiceClient(conn)
	// context.Background()放在后台一直跑，相当于root的上下文
	resp, err := client.Hello(context.Background(), &protocol.Request{Value: "jack"})
	if err != nil {
		panic(err)
	}
	fmt.Println(resp)

	// 返回一个channel io pipe 对象
	// HelloService_ChatClient 对应 HelloService_ChatServer
	stream, err := client.Chat(context.Background())
	if err != nil {
		panic(err)
	}

	// 在客户端我们将发送操作和接收操作放到两个独立的 Goroutine
	// 首先是向服务端发送数据
	go func() {
		for {
			err := stream.Send(&protocol.Request{Value: "jack li"})
			if err != nil {
				fmt.Println(err)
				return
			}
			time.Sleep(1 * time.Second)
		}
	}()

	// 然后在循环中接收服务端返回的数据
	for {
		resp, err := stream.Recv()
		if err != nil {
			fmt.Println(err)
			return
		}
		fmt.Println(resp)
	}
}
```



#### gRPC认证

前面我们的grpc服务 在无任何保护机制下 都可以被任何人调用, 这是很危险的, 因此我们需要为grpc 添加认证的功能

我们在上面的流程中可以得知Grpc有2种模式:

- Request Response模式
- Stream 模式



##### Request Response模式

```
// auth.client
package auth

import "context"

// Authentication todo
type Authentication struct {
	clientID     string
	clientSecret string
}

func NewAuthentication(clientId, clientSecret string) *Authentication {
	return &Authentication{
		clientID:     clientId,
		clientSecret: clientSecret,
	}
}

// 实现PerRPCCredentials接口，返回map认证数据
func (a *Authentication) GetRequestMetadata(ctx context.Context, uri ...string) (map[string]string, error) {
	return map[string]string{ClientIdKey: a.clientID, ClientSecretKey: a.clientSecret}, nil
}

func (a *Authentication) RequireTransportSecurity() bool {
	return false
}
---
// auth.server
package auth

import (
	"context"
	"fmt"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status" // 不能引用 internal的status包，会报错
)

const (
	ClientIdKey     = "client-id"
	ClientSecretKey = "client-secret"
)

// 通过暴露Auth函数，来提供grpc中间件函数
func GrpcAuthUnaryServerInterceptor() grpc.UnaryServerInterceptor {
	return newGrpcAuther().Auth
}

type grpcAuther struct {
}

func newGrpcAuther() *grpcAuther {
	return &grpcAuther{}
}

// 认证逻辑
// http/1.1中有header，grpc使用http/2.0，在grpc中叫做metadata，metadata等价于header
func (a *grpcAuther) Auth(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo,
	handler grpc.UnaryHandler) (resp interface{}, err error) {
	// 从ctx中获取到了metadata信息，所以中间信息都会通过metadata传递，服务端 <-- 客户端
	md, ok := metadata.FromIncomingContext(ctx)
	if ok {
		fmt.Println(md)
	}

	// 认证请求合法性
	clientId, clientSecret := a.GetClientCredentialsFromMeta(md)
	err = a.validateServiceCredential(clientId, clientSecret)
	if err != nil {
		return nil, err
	}

	// 认证通过，请求交给后面的handler处理
	return handler(ctx, req)
}

func (a *grpcAuther) validateServiceCredential(clientId, clientSecret string) error {
	if clientId == "" && clientSecret == "" {
		return status.Errorf(codes.Unauthenticated, "client credential %s, %s not provided", ClientIdKey, ClientSecretKey)
	}

	if !(clientId == "admin" && clientSecret == "123456") {
		return status.Errorf(codes.Unauthenticated, "client-id or client-secret is not correct")
	}

	return nil
}

// 从metadata中获取客户端凭证
func (a *grpcAuther) GetClientCredentialsFromMeta(md metadata.MD) (clientId, clientSecret string) {
	cids := md.Get(ClientIdKey)
	sids := md.Get(ClientSecretKey)

	if len(cids) > 0 {
		clientId = cids[0]
	}

	if len(sids) > 0 {
		clientSecret = sids[0]
	}
	return
}
---
// server.main
package main

import (
	"context"
	"fmt"
	"io"
	"net"

	"github.com/jacknotes/grpc-demo/grpc/auth"
	"github.com/jacknotes/grpc-demo/grpc/protocol"
	"google.golang.org/grpc"
)

type Service struct {
	// 结构体嵌套(必须是匿名)，等价于继承UnimplementedHelloServiceServer，而UnimplementedHelloServiceServer实现了
	// HelloServiceServer接口，所以Service间接实现了HelloServiceServer接口
	protocol.UnimplementedHelloServiceServer
}

// 重写protocol.UnimplementedHelloServiceServer的方法Hello,简单加个hello前缀
func (s *Service) Hello(ctx context.Context, req *protocol.Request) (*protocol.Response, error) {
	return &protocol.Response{
		Value: "hello: " + req.Value,
	}, nil
}

// server --> stream --> client
// 重写，HelloService_ChatServer 对应 HelloService_ChatClient
func (s *Service) Chat(stream protocol.HelloService_ChatServer) error {
	// 可以把stream当成一个channel io pipe对象
	for {
		// 接收客户端请求
		req, err := stream.Recv()
		if err != nil {
			if err == io.EOF {
				fmt.Println("chat exit")
				return nil
			}
			fmt.Println(err)
			return err
		}
		// 处理请求
		err = stream.Send(&protocol.Response{Value: "hello: " + req.Value})
		if err != nil {
			fmt.Println(err)
			return err
		}
	}
}

func main() {
	// 如何把Service 作为一个rpc暴露出去，提供服务
	// 需要将auth.GrpcAuthUnaryServerInterceptor()传给grpc.UnaryInterceptor()，才能成为一个拦截器
	// 请求响应模式的 认证中间件
	server := grpc.NewServer(grpc.UnaryInterceptor(auth.GrpcAuthUnaryServerInterceptor()))

	// Service生成的代码里面，提供了注册函数，把自己注册到grpc的servr内
	protocol.RegisterHelloServiceServer(server, new(Service))

	// 开启grpc服务
	ls, err := net.Listen("tcp", ":1234")
	if err != nil {
		panic(err)
	}
	// 监听grpc服务
	if err := server.Serve(ls); err != nil {
		fmt.Println(err)
	}
}
---
// client.main
package main

import (
	"context"
	"fmt"
	"time"

	"github.com/jacknotes/grpc-demo/grpc/auth"
	"github.com/jacknotes/grpc-demo/grpc/protocol"
	"google.golang.org/grpc"
)

func main() {
	// grpc.WithInsecure()表示不使用tls
	// grpc.WithPerRPCCredentials参数为实现PerRPCCredentials接口的对象，此对象有GetRequestMetadata方法，
	// 此方法会返回ClientIdKey和ClientSecretKey
	conn, err := grpc.Dial("127.0.0.1:1234", grpc.WithInsecure(),
		grpc.WithPerRPCCredentials(auth.NewAuthentication("admin", "1234567")))
	if err != nil {
		panic(err)
	}

	// // 请求时携带指定的metadata信息,通过上下文携带
	// md := metadata.New(map[string]string{auth.ClientIdKey: "admin", auth.ClientSecretKey: "123456"})
	// // 客户端发送时需要携带的上下文信息， 客户端 --> 服务端
	// ctx := metadata.NewOutgoingContext(context.Background(), md)

	client := protocol.NewHelloServiceClient(conn)
	// context.Background()放在后台一直跑，相当于root的上下文
	// resp, err := client.Hello(ctx, &protocol.Request{Value: "jack"})
	resp, err := client.Hello(context.Background(), &protocol.Request{Value: "jack"})
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(resp)
}

```



##### Stream 模式

```go
// auth.client
package auth

import "context"

// Authentication todo
type Authentication struct {
	clientID     string
	clientSecret string
}

func NewAuthentication(clientId, clientSecret string) *Authentication {
	return &Authentication{
		clientID:     clientId,
		clientSecret: clientSecret,
	}
}

// 实现PerRPCCredentials接口，返回map认证数据
func (a *Authentication) GetRequestMetadata(ctx context.Context, uri ...string) (map[string]string, error) {
	return map[string]string{ClientIdKey: a.clientID, ClientSecretKey: a.clientSecret}, nil
}

func (a *Authentication) RequireTransportSecurity() bool {
	return false
}
---
// auth.server
package auth

import (
	"context"
	"fmt"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status" // 不能引用 internal的status包，会报错
)

const (
	ClientIdKey     = "client-id"
	ClientSecretKey = "client-secret"
)

// 通过暴露Auth函数，来提供grpc中间件函数
func GrpcAuthUnaryServerInterceptor() grpc.UnaryServerInterceptor {
	return newGrpcAuther().Auth
}

// 通过暴露StreamAuth函数，来提供grpc stream中间件函数
func GrpcAuthStreamServerInterceptor() grpc.StreamServerInterceptor {
	return newGrpcAuther().StreamAuth
}

type grpcAuther struct {
}

func newGrpcAuther() *grpcAuther {
	return &grpcAuther{}
}

// 认证逻辑
// http/1.1中有header，grpc使用http/2.0，在grpc中叫做metadata，metadata等价于header
func (a *grpcAuther) Auth(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo,
	handler grpc.UnaryHandler) (resp interface{}, err error) {
	// 从ctx中获取到了metadata信息，所以中间信息都会通过metadata传递，服务端 <-- 客户端
	md, ok := metadata.FromIncomingContext(ctx)
	if ok {
		fmt.Println(md)
	}

	// 认证请求合法性
	clientId, clientSecret := a.GetClientCredentialsFromMeta(md)
	err = a.validateServiceCredential(clientId, clientSecret)
	if err != nil {
		return nil, err
	}

	// 认证通过，请求交给后面的handler处理
	return handler(ctx, req)
}

func (a *grpcAuther) validateServiceCredential(clientId, clientSecret string) error {
	if clientId == "" && clientSecret == "" {
		return status.Errorf(codes.Unauthenticated, "client credential %s, %s not provided", ClientIdKey, ClientSecretKey)
	}

	if !(clientId == "admin" && clientSecret == "123456") {
		return status.Errorf(codes.Unauthenticated, "client-id or client-secret is not correct")
	}

	return nil
}

// 从metadata中获取客户端凭证
func (a *grpcAuther) GetClientCredentialsFromMeta(md metadata.MD) (clientId, clientSecret string) {
	cids := md.Get(ClientIdKey)
	sids := md.Get(ClientSecretKey)

	if len(cids) > 0 {
		clientId = cids[0]
	}

	if len(sids) > 0 {
		clientSecret = sids[0]
	}
	return
}

func (a *grpcAuther) StreamAuth(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo,
	handler grpc.StreamHandler) error {
	md, _ := metadata.FromIncomingContext(ss.Context())

	// 认证请求合法性
	clientId, clientSecret := a.GetClientCredentialsFromMeta(md)
	err := a.validateServiceCredential(clientId, clientSecret)
	if err != nil {
		return err
	}

	// 认证通过，请求交给后面的handler处理
	return handler(srv, ss)
}
---
// server.main
package main

import (
	"context"
	"fmt"
	"io"
	"net"

	"github.com/jacknotes/grpc-demo/grpc/auth"
	"github.com/jacknotes/grpc-demo/grpc/protocol"
	"google.golang.org/grpc"
)

type Service struct {
	// 结构体嵌套(必须是匿名)，等价于继承UnimplementedHelloServiceServer，而UnimplementedHelloServiceServer实现了
	// HelloServiceServer接口，所以Service间接实现了HelloServiceServer接口
	protocol.UnimplementedHelloServiceServer
}

// 重写protocol.UnimplementedHelloServiceServer的方法Hello,简单加个hello前缀
func (s *Service) Hello(ctx context.Context, req *protocol.Request) (*protocol.Response, error) {
	return &protocol.Response{
		Value: "hello: " + req.Value,
	}, nil
}

// server --> stream --> client
// 重写，HelloService_ChatServer 对应 HelloService_ChatClient
func (s *Service) Chat(stream protocol.HelloService_ChatServer) error {
	// 可以把stream当成一个channel io pipe对象
	for {
		// 接收客户端请求
		req, err := stream.Recv()
		if err != nil {
			if err == io.EOF {
				fmt.Println("chat exit")
				return nil
			}
			fmt.Println(err)
			return err
		}
		// 处理请求
		err = stream.Send(&protocol.Response{Value: "hello: " + req.Value})
		if err != nil {
			fmt.Println(err)
			return err
		}
	}
}

func main() {
	// 如何把Service 作为一个rpc暴露出去，提供服务
	// 需要将auth.GrpcAuthUnaryServerInterceptor()传给grpc.UnaryInterceptor()，才能成为一个拦截器
	server := grpc.NewServer(
		// 请求响应模式的认证中间件，会走此方法去认证
		grpc.UnaryInterceptor(auth.GrpcAuthUnaryServerInterceptor()),
		// stream模式的认证中间件，会走此方法去认证
		grpc.StreamInterceptor(auth.GrpcAuthStreamServerInterceptor()),
	)

	// Service生成的代码里面，提供了注册函数，把自己注册到grpc的servr内
	protocol.RegisterHelloServiceServer(server, new(Service))

	// 开启grpc服务
	ls, err := net.Listen("tcp", ":1234")
	if err != nil {
		panic(err)
	}
	// 监听grpc服务
	if err := server.Serve(ls); err != nil {
		fmt.Println(err)
	}
}
---
// client.main
package main

import (
	"context"
	"fmt"
	"time"

	"github.com/jacknotes/grpc-demo/grpc/auth"
	"github.com/jacknotes/grpc-demo/grpc/protocol"
	"google.golang.org/grpc"
)

func main() {
	// grpc.WithInsecure()表示不使用tls
	// grpc.WithPerRPCCredentials参数为实现PerRPCCredentials接口的对象，此对象有GetRequestMetadata方法，
	// 此方法会返回ClientIdKey和ClientSecretKey
	conn, err := grpc.Dial("127.0.0.1:1234", grpc.WithInsecure(),
		grpc.WithPerRPCCredentials(auth.NewAuthentication("admin", "123456")))
	if err != nil {
		panic(err)
	}

	// // 请求时携带指定的metadata信息,通过上下文携带
	// md := metadata.New(map[string]string{auth.ClientIdKey: "admin", auth.ClientSecretKey: "123456"})
	// // 客户端发送时需要携带的上下文信息， 客户端 --> 服务端
	// ctx := metadata.NewOutgoingContext(context.Background(), md)

	client := protocol.NewHelloServiceClient(conn)
	// context.Background()放在后台一直跑，相当于root的上下文
	// resp, err := client.Hello(ctx, &protocol.Request{Value: "jack"})
	resp, err := client.Hello(context.Background(), &protocol.Request{Value: "jack"})
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(resp)

	// 返回一个channel io pipe 对象
	// HelloService_ChatClient 对应 HelloService_ChatServer
	stream, err := client.Chat(context.Background())
	if err != nil {
		panic(err)
	}

	// 在客户端我们将发送操作和接收操作放到两个独立的 Goroutine
	// 首先是向服务端发送数据
	go func() {
		for {
			err := stream.Send(&protocol.Request{Value: "jack li"})
			if err != nil {
				fmt.Println(err)
				return
			}
			time.Sleep(1 * time.Second)
		}
	}()

	// 然后在循环中接收服务端返回的数据
	for {
		resp, err := stream.Recv()
		if err != nil {
			fmt.Println(err)
			return
		}
		fmt.Println(resp)
	}
}
```

注：client.main，使用了请求响应模式和stream模式，各自走不同的认证中间件





### gRPC demo

[jacknotes/restful-api-demo at app-grpc (github.com)](https://github.com/jacknotes/restful-api-demo/tree/app-grpc)



### mcube脚手架生成框架

#### v1

```
# 安装protobuf自动注入tag工具，因为protobuf本身不支持注入tag 
go install github.com/favadi/protoc-go-inject-tag@latest


# 安装脚手架工具
$ go install github.com/infraboard/mcube/cmd/mcube@v1.5.9
```

```
$ mcube.exe init
? 请输入项目包名称: github.com/jacknotes/cmdb
? 请输入项目描述: cmdb
? 是否接入权限中心[keyauth] (y/N) y
? Keyauth GRPC服务地址: 127.0.0.1:18050
? Keyauth Client ID: abc
? 选择数据库类型: MySQL
? MySQL服务地址: (127.0.0.1:3306) 192.168.15.203:3306

? MySQL服务地址: 192.168.15.203:3306
? 数据库名称: cmdb
? 用户: jack
? 密码: ******
? 生成样例代码 Y
项目初始化完成, 项目结构如下: 
├───.gitignore (269b)
├───.vscode
│       └───settings.json (64b)
├───README.md (3703b)
├───apps
│       ├───all
│       │       ├───grpc.go (168b)
│       │       ├───http.go (138b)
│       │       └───internal.go (107b)
│       └───book
│               ├───app.go (2213b)
│               ├───http
│               │       ├───book.go (2186b)
│               │       └───http.go (1093b)
│               ├───impl
│               │       ├───book.go (3972b)
│               │       ├───dao.go (715b)
│               │       ├───impl.go (843b)
│               │       └───sql.go (325b)
│               └───pb
│                       └───book.proto (2232b)
├───client
│       ├───client.go (861b)
│       ├───client_test.go (454b)
│       └───config.go (164b)
├───cmd
│       ├───init.go (1199b)
│       ├───root.go (1261b)
│       └───start.go (3819b)
├───conf
│       ├───config.go (4702b)
│       ├───load.go (720b)
│       └───log.go (365b)
├───docs
│       ├───README.md (15b)
│       └───schema
│               └───tables.sql (849b)
├───etc
│       ├───config.env (470b)
│       ├───config.toml (391b)
│       └───unit-test.env (17b)
├───go.mod (32b)
├───main.go (89b)
├───makefile (2518b)
├───protocol
│       ├───grpc.go (1520b)
│       └───http.go (2948b)
└───version
        └───version.go (628b)
        
# 初始化配置        
$ cd cmdb/       
$ make install   
# protobuf 文件需要import,而会从/usr/local/include中查找 
$ \cp -a C:\Users\jack\go\pkg\mod\github.com "C:\Program Files\Git\usr\local\include"
$ cd "C:\Program Files\Git\usr\local\include\github.com\infraboard"
$ mv mcube@v1.5.9 mcube 
$ make gen
$ make dep

# 初始化，生成mysql的表
$ make init 
fatal: not a git repository (or any of the parent directories): .git
fatal: not a git repository (or any of the parent directories): .git
执行的SQL: 
CREATE TABLE IF NOT EXISTS `books` (
  `id` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '对象Id',
  `create_at` bigint NOT NULL COMMENT '创建时间(13位时间戳)',
  `create_by` varchar(255) COLLATE utf8mb4_general_ci NOT NULL COMMENT '创建人',
  `update_at` bigint NOT NULL COMMENT '更新时间',
  `update_by` varchar(255) COLLATE utf8mb4_general_ci NOT NULL COMMENT '更新人',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '书名',
  `author` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '作者',
  PRIMARY KEY (`id`),
  KEY `idx_name` (`name`) USING BTREE COMMENT '用于书名搜索',
  KEY `idx_author` (`author`) USING BTREE COMMENT '用于作者搜索'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 运行项目
$ make run 
fatal: not a git repository (or any of the parent directories): .git
fatal: not a git repository (or any of the parent directories): .git
2023-01-08T13:34:07.397+0800    INFO    [INIT]  cmd/start.go:155        log level: debug
2023-01-08T13:34:07.424+0800    INFO    [CLI]   cmd/start.go:94 loaded grpc app: [book]
2023-01-08T13:34:07.424+0800    INFO    [CLI]   cmd/start.go:95 loaded http app: [book]
2023-01-08T13:34:07.425+0800    INFO    [CLI]   cmd/start.go:96 loaded internal app: []
2023-01-08T13:34:07.425+0800    INFO    [HTTP Service]  protocol/http.go:106    start registry endpoints ...
2023-01-08T13:34:07.426+0800    INFO    [GRPC Service]  protocol/grpc.go:59     GRPC 服务监听地址: 127.0.0.1:18050
2023-01-08T13:34:07.932+0800    WARN    [HTTP Service]  protocol/http.go:111    registry endpoints error, rpc error: code = Unimplemented desc = unknown service infraboard.keyauth.endpoint.Service
2023-01-08T13:34:07.934+0800    INFO    [HTTP Service]  protocol/http.go:82     HTTP服务启动成功, 监听地址: 127.0.0.1:8050
```



#### v2

```
# 安装脚手架工具 v1.6.1
$ go install github.com/infraboard/mcube/cmd/mcube@v1.6.1
go: downloading github.com/infraboard/mcube v1.6.1

$ pwd
/d/share/golang-study/day16
$ mcube.exe init 
? 请输入项目包名称: github.com/jacknotes/cmdb
? 请输入项目描述: 资产管理系统
? 是否接入权限中心[keyauth] (y/N) y
? Keyauth GRPC服务地址: 127.0.0.1:18050
? Keyauth Client ID: abc
? Keyauth Client Secret: ***
? 选择数据库类型:  [Use arrows to move, type to filter]
> MySQL
  MongoDB
? 选择数据库类型: MySQL
? MySQL服务地址: (127.0.0.1:3306) 192.168.15.203:3306

? MySQL服务地址: 192.168.15.203:3306
? 数据库名称: cmdb
? 用户: jack
? 密码: ******
? 生成样例代码 (y/N) y
项目初始化完成, 项目结构如下: 
├───.gitignore (269b)
├───README.md (4214b)
├───apps
│       ├───all
│       │       ├───grpc.go (168b)
│       │       ├───http.go (138b)
│       │       └───internal.go (107b)
│       └───book
│               ├───app.go (2213b)
│               ├───http
│               │       ├───book.go (2186b)
│               │       └───http.go (1093b)
│               ├───impl
│               │       ├───book.go (3972b)
│               │       ├───dao.go (715b)
│               │       ├───impl.go (843b)
│               │       └───sql.go (325b)
│               └───pb
│                       └───book.proto (2232b)
├───client
│       ├───client.go (861b)
│       ├───client_test.go (454b)
│       └───config.go (164b)
├───cmd
│       ├───init.go (1199b)
│       ├───root.go (1289b)
│       └───start.go (3819b)
├───conf
│       ├───config.go (4702b)
│       ├───load.go (720b)
│       └───log.go (365b)
├───docs
│       ├───README.md (15b)
│       └───schema
│               └───tables.sql (849b)
├───etc
│       ├───config.env (470b)
│       └───config.toml (391b)
├───go.mod (32b)
├───main.go (89b)
├───makefile (2518b)
├───protocol
│       ├───grpc.go (1520b)
│       └───http.go (2948b)
└───version
        └───version.go (628b)
        
$ cd cmdb && code .
$ make install 
fatal: not a git repository (or any of the parent directories): .git
fatal: not a git repository (or any of the parent directories): .git

# protobuf 文件需要import github.com/infraboard/mcube中的protobuf文件,而会从/usr/local/include中查找
$ go get github.com/infraboard/mcube@v1.6.1
go get: added github.com/infraboard/mcube v1.6.1 
$ rm -rf /c/Program\ Files/Git/usr/local/include/github.com/infraboard/mcube
$ \cp -a /c/Users/jack/go/pkg/mod/github.com/infraboard/mcube\@v1.6.1/ /c/Program\ Files/Git/usr/local/include/github.com/infraboard/mcube

# 注释 Makefile文件 gen的一行enum配置
gen: ## Init Service
	@protoc -I=.  -I=/usr/local/include --go_out=. --go_opt=module=${PKG} --go-grpc_out=. --go-grpc_opt=module=${PKG} apps/*/pb/*.proto

	@protoc-go-inject-tag -input=apps/*/*.pb.go
#	@mcube enum -p -m apps/*/*.pb.go
---

$ make gen
$ make dep

# 初始化，生成mysql的表
$ make init 
fatal: not a git repository (or any of the parent directories): .git
fatal: not a git repository (or any of the parent directories): .git
执行的SQL: 
CREATE TABLE IF NOT EXISTS `books` (
  `id` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '对象Id',
  `create_at` bigint NOT NULL COMMENT '创建时间(13位时间戳)',
  `create_by` varchar(255) COLLATE utf8mb4_general_ci NOT NULL COMMENT '创建人',
  `update_at` bigint NOT NULL COMMENT '更新时间',
  `update_by` varchar(255) COLLATE utf8mb4_general_ci NOT NULL COMMENT '更新人',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '书名',
  `author` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '作者',
  PRIMARY KEY (`id`),
  KEY `idx_name` (`name`) USING BTREE COMMENT '用于书名搜索',
  KEY `idx_author` (`author`) USING BTREE COMMENT '用于作者搜索'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 运行项目
$ make run
fatal: not a git repository (or any of the parent directories): .git
fatal: not a git repository (or any of the parent directories): .git
2023-01-08T14:10:36.936+0800    INFO    [INIT]  cmd/start.go:155        log level: debug
2023-01-08T14:10:36.965+0800    INFO    [CLI]   cmd/start.go:94 loaded grpc app: [book]
2023-01-08T14:10:36.965+0800    INFO    [CLI]   cmd/start.go:95 loaded http app: [book]
2023-01-08T14:10:36.965+0800    INFO    [CLI]   cmd/start.go:96 loaded internal app: []
2023-01-08T14:10:36.965+0800    INFO    [HTTP Service]  protocol/http.go:106    start registry endpoints ...
2023-01-08T14:10:36.967+0800    INFO    [GRPC Service]  protocol/grpc.go:59     GRPC 服务监听地址: 127.0.0.1:18050
2023-01-08T14:10:37.474+0800    WARN    [HTTP Service]  protocol/http.go:111    registry endpoints error, rpc error: code = Unimplemented desc = unknown service infraboard.keyauth.endpoint.Service
2023-01-08T14:10:37.475+0800    INFO    [HTTP Service]  protocol/http.go:82     HTTP服务启动成功, 监听地址: 127.0.0.1:8050
```



