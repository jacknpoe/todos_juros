extern "C" {

// Symbols from linker
extern unsigned long _estack;

// Handlers
void Reset_Handler(void);
void Default_Handler(void);

// Vector table
__attribute__((section(".isr_vector")))
void (* const vector_table[])(void) = {
    (void (*)(void))(&_estack),
    Reset_Handler,
    Default_Handler,
    Default_Handler,
    Default_Handler,
    Default_Handler,
    Default_Handler,
    0, 0, 0, 0,
    Default_Handler,
    Default_Handler,
    0,
    Default_Handler,
    Default_Handler
};

}

// Declare main with C linkage to avoid pedantic warning
extern void app_main(void);

extern "C" void initialise_monitor_handles(void);

extern "C" void Reset_Handler(void) {
    initialise_monitor_handles();
    app_main();
    while (1) {}
}

extern "C" void Default_Handler(void) {
    while (1) {}
}
