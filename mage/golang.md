

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





#### day06



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







#### day07



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





#### day08*

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







#### day09

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

