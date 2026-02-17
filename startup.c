// para compilar jurosELF.c

extern int main(void);

void Reset_Handler(void) {
    main();
    while (1) {}
}

__attribute__((section(".isr_vector")))
void (* const vector_table[])(void) = {
    (void (*)(void)) (0x20008000), // stack top (32 KB RAM, ok para lm3s)
    Reset_Handler
};
