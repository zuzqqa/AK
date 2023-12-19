.386
rozkazy SEGMENT     use16
        ASSUME      CS:rozkazy

obsluga_zegara      PROC 
        push    ax
        push    bx
        push    es

        inc     cs:czas
        cmp     cs:czas, 18
        jb      zakoncz_obsluge_zegara

        mov     cs:czas, 0

        mov     ax, 0B800H
        mov     es, ax

 kontynuuj:
        cmp     cs:licznik_gw97, 97
        je      zakoncz_obsluge_zegara

        xor     bx, bx
        mov     bx, cs:licznik

        mov     byte PTR es:[bx], '*'  

        inc     cs:licznik_gw24
        inc     cs:licznik_gw97
        cmp     cs:licznik_gw24, 24
        je      kolejna_kolumna

        add     bx, 160

wysw_dalej:
        mov     cs:licznik, bx
        jmp     zakoncz_obsluge_zegara

kolejna_kolumna:
        mov     cs:licznik_gw24, 0
        add     cs:kolumna, 6
        xor     dx, dx
        mov     dx, cs:kolumna
        mov     cs:licznik, dx
        jmp     kontynuuj 

zakoncz_obsluge_zegara:
        pop     es
        pop     bx
        pop     ax

        jmp     dword PTR cs:wektor8

licznik         dw      0
wektor8         dd      ?
czas            dw      0
licznik_gw24    dw      0
licznik_gw97    dw      0
kolumna         dw      0
obsluga_zegara          ENDP

zacznij:
        mov     al, 0
        mov     ah, 5
        int     10

        mov     ax, 0
        mov     ds, ax

        mov     eax, ds:[32]
        mov     cs:wektor8, eax

        cmp     cs:licznik_gw97, 97
        je      koniec

        mov     ax, SEG obsluga_zegara 
        mov     bx, OFFSET obsluga_zegara 

        cli

        mov     ds:[32], bx
        mov     ds:[34], ax

        sti 

aktywne_oczekiwanie:
        mov     ah, 1
        int     16H

        jz aktywne_oczekiwanie

        mov     ah, 0
        int     16H
        cmp     al, 'x'
        jne     aktywne_oczekiwanie

koniec:
        mov     eax, cs:wektor8
        cli     
        mov     ds:[32], eax

        sti

; zakonczenie programu
        mov     al, 0
        mov     ah, 4CH
        int     21H
rozkazy ENDS

nasz_stos       SEGMENT stack
        db      256 dup (?)
nasz_stos ENDS

END zacznij
