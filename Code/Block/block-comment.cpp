int globalVal = 1;
static int staticGlobalVal = 2;

// flags/_flags类型
enum {
  /* See function implementation for a more complete description of these fields and combinations */
  // 是一个对象
  BLOCK_FIELD_IS_OBJECT   =  3,  /* id, NSObject, __attribute__((NSObject)), block, ... */
  // 是一个block
  BLOCK_FIELD_IS_BLOCK    =  7,  /* a block variable */
  // 被__block修饰的变量
  BLOCK_FIELD_IS_BYREF    =  8,  /* the on stack structure holding the __block variable */
  // 被__weak修饰的变量，只能被辅助copy函数使用
  BLOCK_FIELD_IS_WEAK     = 16,  /* declared __weak, only used in byref copy helpers */
  // block辅助函数调用（告诉内部实现不要进行retain或者copy）
  BLOCK_BYREF_CALLER      = 128  /* called from __block (byref) copy/dispose support routines. */
};

struct __block_impl {
  void *isa;       // isa指针，指向对象所属类型
  int Flags;       // 标志变量，在实现block内部操作时用到，比如copy时加入BLOCK_NEED_FREE标志
  int Reserved;    // 保留字段
  void *FuncPtr;   // 函数指针，指向block执行时调用的函数
};

/*
 * 用__block修饰的变量会被转换成这样一个结构体
 * 成员分别是__isa指针，指向自身类型的__forwarding指针，__flags标志位，__size大小，blockVal是变量值和变量名同名
 * __forwarding 指针是针对block拷贝到堆上设计的
 * 当block在栈上的时候，__forwarding指向结构体本身，当block被拷贝到堆上的时候，__forwaring改为指向堆上这个结构体的拷贝，这样总是能通过val->__forwarding->val访问到变量值
 */
// 非对象变量
struct __Block_byref_blockVal_0 {
  void *__isa;
  __Block_byref_blockVal_0 *__forwarding;
 int __flags;
 int __size;
 int blockVal;
};
// 对象变量
/*
 * 对象变量的结构体会增加两个方法，用于对对象进行内存管理，在block执行拷贝和销毁的时候调用
 */
struct __Block_byref_blockObj_1 {
  void *__isa;
  __Block_byref_blockObj_1 *__forwarding;
 int __flags;
 int __size;
 void (*__Block_byref_id_object_copy)(void*, void*);
 void (*__Block_byref_id_object_dispose)(void*);
 NSObject *blockObj;
};

struct __main_block_impl_0 {
  struct __block_impl impl;          // block的实现
  struct __main_block_desc_0* Desc;  // block的描述
  /*
   * 被捕获的变量
   * 普通变量直接捕获值
   * 局部静态变量传递的是内存地址
   */
  int *staticVal;
  int val;
  /*
   * __block修饰的变量
   */
  __Block_byref_blockVal_0 *blockVal; // by ref
  __Block_byref_blockObj_1 *blockObj; // by ref
  /*
   * 构造函数
   * 初始化block的isa指针，指明其类型
   * 初始化函数指针，执行block时调用
   * 初始化捕获的变量
   * __block修饰的变量，会将其结构体的__forwarding指向它自己
   * 初始化标志位和描述
   */
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int *_staticVal, int _val, __Block_byref_blockVal_0 *_blockVal, int flags=0) : staticVal(_staticVal), val(_val), blockVal(_blockVal->__forwarding), blockObj(_blockObj->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

/*
 * block执行调用的函数
 */
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  __Block_byref_blockVal_0 *blockVal = __cself->blockVal; // bound by ref
  __Block_byref_blockObj_1 *blockObj = __cself->blockObj; // bound by ref
  int *staticVal = __cself->staticVal; // bound by copy
  int val = __cself->val; // bound by copy
  /*
   * 全局变量和全局静态变量由于作用域是全局的，同时存储在全局静态区，所以直接访问对应的变量，不会捕获作为block的成员
   */
  globalVal++;
  staticGlobalVal++;
  /*
   * 局部静态变量虽然也是存储在全局静态区，生命周期和程序一致，但作用域限定在定义它的函数内，所以block会捕获它作为成员，通过其内存地址进行访问
   */
  (*staticVal)++;
  /*
   * __block修饰的变量
   */
  (blockVal->__forwarding->blockVal)++;
  /*
   * 直接捕获值无法修改
   */
   val;
   (blockObj->__forwarding->blockObj);
}

/*
 * 在block执行copy时对block捕获的对象变量和__block变量转换的对象进行拷贝操作，同时block持有这些变量
 */
static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {_Block_object_assign((void*)&dst->blockVal, (void*)src->blockVal, 8/*BLOCK_FIELD_IS_BYREF*/);_Block_object_assign((void*)&dst->blockObj, (void*)src->blockObj, 8/*BLOCK_FIELD_IS_BYREF*/);}
/*
 * 在block执行dispose(销毁)时对block捕获的对象变量和__block变量转换的对象进行释放操作，引用计数为0是销毁对象
 */
static void __main_block_dispose_0(struct __main_block_impl_0*src) {_Block_object_dispose((void*)src->blockVal, 8/*BLOCK_FIELD_IS_BYREF*/);_Block_object_dispose((void*)src->blockObj, 8/*BLOCK_FIELD_IS_BYREF*/);}

/*
 * 定义一个block描述结构体
 * 初始化一个描述结构体作为参数传递给block构造函数用于初始化block
 */
static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
  void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};
int main(int argc, const char * argv[]) {
    static int staticVal = 3;
    int val = 4;
    /*
     * 用__block修饰的blockVal变量会被替换成一个结构体，也是一个对象
     * 之后访问这个变量都是以blockVal->__forwarding->blockVal的方式访问，block外和block内都是
     */
    __attribute__((__blocks__(byref))) __Block_byref_blockVal_0 blockVal = {(void*)0,(__Block_byref_blockVal_0 *)&blockVal, 0, sizeof(__Block_byref_blockVal_0), 4};
    __attribute__((__blocks__(byref))) __Block_byref_blockObj_1 blockObj = {(void*)0,(__Block_byref_blockObj_1 *)&blockObj, 33554432, sizeof(__Block_byref_blockObj_1), __Block_byref_id_object_copy_131, __Block_byref_id_object_dispose_131, ((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSObject"), sel_registerName("new"))};
    void (*block)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, &staticVal, val, (__Block_byref_blockVal_0 *)&blockVal, (__Block_byref_blockObj_1 *)&blockObj, 570425344));
    (blockVal.__forwarding->blockVal)++;
}
