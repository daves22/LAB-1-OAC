        .data
a:      .float 5.0
b:      .float -5.0
c:      .float 6.0
msg:    .asciz "Retorno: "
nl:     .asciz "\n"

        .text
        .globl main

main:
        # carrega constantes em fa0-fa2
        la   t0, a
        flw  fa0, 0(t0)          # a
        la   t0, b
        flw  fa1, 0(t0)          # b
        la   t0, c
        flw  fa2, 0(t0)          # c

        jal  ra, baskara         # chama função
        mv   t1, a0              # guarda retorno

        # imprime "Retorno: "
        la   a0, msg
        li   a7, 4               # ecall 4 = print_string
        ecall

        # imprime valor numérico
        mv   a0, t1
        li   a7, 1               # ecall 1 = print_int
        ecall

        la   a0, nl
        li   a7, 4
        ecall


        li   a7, 10              # ecall 10 = exit
        ecall



        .globl baskara
baskara:
        addi sp, sp, -12
        sw   ra, 8(sp)

        # ft0 ← 0,0
        fcvt.s.w ft0, zero

        # se a == 0  → erro
        feq.s t0, fa0, ft0
        bnez  t0, erro

        # delta = b² − 4ac
        fmul.s ft1, fa1, fa1         # b²
        li    t0, 4
        fcvt.s.w ft2, t0             # 4.0
        fmul.s ft2, ft2, fa0         # 4a
        fmul.s ft2, ft2, fa2         # 4ac
        fsub.s ft3, ft1, ft2         # Δ

        # delta < 0 ?
        flt.s t0, ft3, ft0
        bnez  t0, complexas

######## raízes reais 
reais:
        fsqrt.s ft4, ft3             # sqrt(delta)
        fadd.s  ft5, fa0, fa0        # 2a   

        fneg.s ft6, fa1              # -b
        fadd.s ft6, ft6, ft4         # -b + sqrt(delta)
        fdiv.s ft6, ft6, ft5         # x1

        fneg.s ft7, fa1
        fsub.s ft7, ft7, ft4         # -b - sqrt(delta)
        fdiv.s ft7, ft7, ft5         # x2

        fsw   ft7, 0(sp)             # empilha x2
        fsw   ft6, 4(sp)             # empilha x1
        li    a0, 1
        j     fim

######## raízes complexas
complexas:
        # parte real = -b / (2a)
        fneg.s ft6, fa1
        fadd.s ft5, fa0, fa0         # 2a
        fdiv.s ft6, ft6, ft5

        # parte imag = sqrt(delta) / (2a)
        fneg.s ft3, ft3              # |delta|
        fsqrt.s ft7, ft3
        fdiv.s ft7, ft7, ft5

        fsw   ft7, 0(sp)             # imag
        fsw   ft6, 4(sp)             # real
        li    a0, 2
        j     fim

# ######## erro
erro:
        li    a0, 0                  # nada empilhado


######### final
fim:
        lw   ra, 8(sp)
        addi sp, sp, 12
        ret
