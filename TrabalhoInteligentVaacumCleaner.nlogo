breed[ aspiradores aspirador ]
aspiradores-own[ energiaAtual ticksPCarregar capAtual carregando despejando ticksPDespejar LocalCarregadorX LocalCarregadorY LocalDepositoX LocalDepositoY movimentos-restantes estragado]

to setup
  reset-ticks
  setup-patches
  setup-turtles
end

to setup-patches

  clear-all
  set-patch-size 15
  reset-ticks
  ask n-of nCarregadores patches
  [
    set pcolor blue
  ]

  ask n-of pLixo patches with [pcolor = black]
  [
    set pcolor red
  ]

  let nObstaculo random 101;
  ask n-of nObstaculo patches with [pcolor = black]
  [
    set pcolor white
  ]

  let deposito one-of patches
  let px [pxcor] of deposito
  let py [pycor] of deposito

  ;; encontra um espaco onde caiba um 2x2 e nao pinte por cima de outras celulas
  while [px >= max-pxcor or py >= max-pycor or
    [pcolor] of patch px py != black or
    [pcolor] of patch (px + 1) py != black or
    [pcolor] of patch px (py + 1) != black or
    [pcolor] of patch (px + 1) (py + 1) != black] [

    set deposito one-of patches
    set px [pxcor] of deposito
    set py [pycor] of deposito
  ]

  ask patch px py [
    set pcolor green
  ]
  ask patch (px + 1) py [
    set pcolor green
  ]
  ask patch px (py + 1) [
    set pcolor green
  ]
  ask patch (px + 1) (py + 1) [
    set pcolor green
  ]

  if tapete? [
    let tapete one-of patches
    let px-t [pxcor] of tapete
    let py-t [pycor] of tapete

    ;; encontra um espaço onde caiba um 3x3 e não pinte por cima de outras células
    while [px-t >= max-pxcor - 1 or py-t >= max-pxcor - 1 or
      [pcolor] of patch px-t py-t != black or
      [pcolor] of patch (px-t + 1) py-t != black or
      [pcolor] of patch (px-t + 2) py-t != black or
      [pcolor] of patch px-t (py-t + 1) != black or
      [pcolor] of patch px-t (py-t + 2) != black or
      [pcolor] of patch (px-t + 1) (py-t + 1) != black or
      [pcolor] of patch (px-t + 1) (py-t + 2) != black or
      [pcolor] of patch (px-t + 2) (py-t + 1) != black or
      [pcolor] of patch (px-t + 2) (py-t + 2) != black] [

      set tapete one-of patches
      set px-t [pxcor] of tapete
      set py-t [pycor] of tapete
    ]
    ;; Pinta todos os patches da área 3x3 de cinzento (grey)
    ask patch px-t py-t [
      set pcolor grey
    ]
    ask patch (px-t + 1) py-t [
      set pcolor grey
    ]
    ask patch (px-t + 2) py-t [
      set pcolor grey
    ]
    ask patch px-t (py-t + 1) [
      set pcolor grey
    ]
    ask patch (px-t + 1) (py-t + 1) [
      set pcolor grey
    ]
    ask patch (px-t + 2) (py-t + 1) [
      set pcolor grey
    ]
    ask patch px-t (py-t + 2) [
      set pcolor grey
    ]
    ask patch (px-t + 1) (py-t + 2) [
      set pcolor grey
    ]
    ask patch (px-t + 2) (py-t + 2) [
      set pcolor grey
    ]
  ]
end

to setup-turtles
  clear-turtles
  create-aspiradores nAspiradores[
    set LocalCarregadorX 1000
    set LocalCarregadorY 1000
    set localDepositoY 1000
    set localDepositoX 1000
    set shape "circle"
    set color yellow
    set energiaAtual nEnergia - 1
    set heading 90
    setxy random-xcor random-ycor
    set ticksPCarregar tCarga
    set ticksPDespejar tDespejar
    set carregando false
    set despejando false

    ifelse defeitos-aspirador?[
      ifelse random 2 = 0 [
        set estragado true
        set movimentos-restantes random 151 + 50 ;; entre 50 e 200 movimentos de vida
      ] [
        set estragado false
        set movimentos-restantes -1  ;; não estragado, sem limite de movimentos
      ]
    ][set estragado false]
  ]
end

to go

  if count turtles = 0 or not any? patches with [pcolor = red]
  [stop]
  MoveAspiradores
    ask aspiradores [
    if reproducao?[
      let r random 100
      if r < 49[reproduzir]
    ]
  ]
  tick
end

to MoveAspiradores
  ask aspiradores [
    if energiaAtual <= 0[
      ask patch-here [set pcolor white]
      die
    ]
    verifica-estragado
    verificar-celulas
    infoNeighbour
    ifelse carregando = true[tempoCarga]
    [
      ifelse despejando = true[tempoDespejo]
      [
        ifelse energiaAtual <= nIrCarregar [
          ;; Se a energiaAtual for suficiente e a capacidade não estiver cheia
          if not e-parede?[ procura-carregador ]
        ]
        [
          ifelse capAtual >= nCapacidade or not any? patches with [pcolor = red] [
            ;; Se a energiaAtual for baixa, procurar carregador
            if not e-parede?[ procura-deposito ]
          ]
          [
            ifelse energiaAtual >= nIrCarregar and capAtual < nCapacidade [
              ;; Se a capacidade estiver abaixo do limite, procurar depósito
              if not e-parede?[ procura-lixo]
            ]
            [
              ;; Se nenhuma das condições anteriores for verdade
              if not e-parede?[ movimento-livre ]
            ]
          ]
        ]
      ]
    ]
  ]
end

to movimento-livre
  let r random 4
  ifelse (r = 1)[
    let r1 random 2
    ifelse r1 = 0 [left 90][right 90]
    ;left 90
    if not e-branco?
    [
      ifelse e-tapete? [forward 0.25][forward 1]
      set energiaAtual energiaAtual - 1
    ]
  ];;true

  [if not e-branco?
    [
      ifelse e-tapete? [forward 0.25][forward 1]
      set energiaAtual energiaAtual - 1
    ]
  ];;false
end

to movimento-procura-carregador
  ask aspiradores [
    ;; Verifica se está na direção correta em relação ao carregador
    ifelse (ycor < LocalCarregadorY and heading = 0) or
    (xcor < LocalCarregadorX and heading = 90) or
    (ycor > LocalCarregadorY and heading = 180) or
    (xcor > LocalCarregadorX and heading = 270)
    [
      ;; Verifica se o patch à frente é branco
      if patch-ahead 1 != nobody and [pcolor] of patch-ahead 1 = white [
        ;; Gira aleatoriamente para encontrar um caminho livre
        let r random 2
        ifelse (r = 0)
        [ right 90 ] ;; Gira à direita
        [ left 90 ]  ;; Gira à esquerda
      ]
      ;; Se o patch à frente não for branco, anda para a frente
      ifelse e-tapete? [forward 0.25][forward 1]
      set energiaAtual energiaAtual - 1
    ]
    [
      ;; Verifica se está alinhado no eixo x ou y em relação ao carregador e se precisa ajustar a direção
      ifelse (ycor = LocalCarregadorY and heading = 0 and xcor < LocalCarregadorX) or
      (ycor = LocalCarregadorY and heading = 180 and xcor > LocalCarregadorX) or
      (xcor = LocalCarregadorX and heading = 90 and ycor > LocalCarregadorY) or
      (xcor = LocalCarregadorX and heading = 270 and ycor < LocalCarregadorY) or
      (xcor = LocalCarregadorX and heading = 0 and ycor > LocalCarregadorY)
      [
        if [pcolor] of patch-ahead 1 = white [
          let r random 2
          ifelse (r = 0)
          [ right 90 ]
          [ left 90 ]
        ]
        ;; Gira à direita se o caminho estiver livre, caso não haja objetos
        right 90
      ]
      [
        ;; Verifica se deve girar à esquerda
        ifelse (ycor = LocalCarregadorY and heading = 0 and xcor > LocalCarregadorX) or
        (ycor = LocalCarregadorY and heading = 180 and xcor < LocalCarregadorX) or
        (xcor = LocalCarregadorX and heading = 90 and ycor < LocalCarregadorY) or
        (xcor = LocalCarregadorX and heading = 270 and ycor > LocalCarregadorY) or
        (xcor = LocalCarregadorX and heading = 180 and ycor < LocalCarregadorY)
        [
          if [pcolor] of patch-ahead 1 = white [
            let r random 2
            ifelse (r = 0)
            [ right 90 ] ;; Gira à direita
            [ left 90 ]  ;; Gira à esquerda
          ]
          ;; Gira à esquerda se o caminho estiver livre
          left 90
        ]
        [
          ;; Movimentos aleatórios, garantindo que o caminho esteja livre
          if random 100 < 90 [
            if patch-ahead 1 != nobody and [pcolor] of patch-ahead 1 != white [
              ;; Move-se para frente se o caminho estiver livre
              ifelse e-tapete? [forward 0.25][forward 1]
              set energiaAtual energiaAtual - 1
            ]
          ]
          ;; Se não encontrar uma rota, gira aleatoriamente
          ifelse random 100 < 50
          [ right 90 ]
          [ left 90 ]
        ]
      ]
    ]
  ]
end

to procura-lixo
  ifelse ([pcolor] of patch-ahead 1 = red) [
    ifelse e-tapete? [forward 0.25][forward 1]
    ask patch-here [ set pcolor black ]
    set capAtual capAtual + 1
  ]
  [
    ifelse (patch-right-and-ahead 90 1 != nobody and [pcolor] of patch-right-and-ahead 90 1 = red) [
      right 90
      ifelse e-tapete? [forward 0.25][forward 1]
      ask patch-here [ set pcolor black ]
      set capAtual capAtual + 1
    ]
    [
      ifelse (patch-right-and-ahead -90 1 != nobody and [pcolor] of patch-right-and-ahead -90 1 = red) [
        left 90
        ifelse e-tapete? [forward 0.25][forward 1]
        ask patch-here [ set pcolor black ]
        set capAtual capAtual + 1
      ]
      [
        if (patch-ahead -1 != nobody and [pcolor] of patch-ahead -1 = red) [
          right 180
          ifelse e-tapete? [forward 0.25][forward 1]
          ask patch-here [ set pcolor black ]
          set capAtual capAtual + 1
        ]

        ;; Se não encontrar lixo, faz o movimento livre
        if not e-parede?[ movimento-livre ] ;;
      ]
    ]
  ]
end

to procura-carregador
  if energiaAtual <= nIrCarregar [
    set color red
    ifelse ([pcolor] of patch-ahead 1 = blue) [
      ifelse e-tapete? [forward 0.25][forward 1]
      if (localCarregadorX = 1000 and localCarregadorY = 1000)
      [
        set localCarregadorX [pxcor] of patch-here
        set localCarregadorY [pycor] of patch-here
      ]
      set carregando true
      set energiaAtual 100
      set color yellow
    ]
    [
      ifelse (patch-right-and-ahead 90 1 != nobody and [pcolor] of patch-right-and-ahead 90 1 = blue) [
        right 90
        ifelse e-tapete? [forward 0.25][forward 1]

        if (localCarregadorX = 1000 and localCarregadorY = 1000)
        [
          set localCarregadorX [pxcor] of patch-here
          set localCarregadorY [pycor] of patch-here
        ]
        set carregando true
        set energiaAtual 100
        set color yellow
      ]
      [
        ifelse (patch-right-and-ahead -90 1 != nobody and [pcolor] of patch-right-and-ahead -90 1 = blue) [
          left 90
          ifelse e-tapete? [forward 0.25][forward 1]
          if (localCarregadorX = 1000 and localCarregadorY = 1000)
          [
            set localCarregadorX [pxcor] of patch-here
            set localCarregadorY [pycor] of patch-here
          ]
          set carregando true
          set energiaAtual 100
          set color yellow
        ]
        [
          if ( patch-at 0 -1 != nobody and [pcolor] of patch-at 0 -1 = blue) [
            right 180
            ifelse e-tapete? [forward 0.25][forward 1]
            if (localCarregadorX = 1000 and localCarregadorY = 1000)
            [
              set localCarregadorX [pxcor] of patch-here
              set localCarregadorY [pycor] of patch-here
            ]
            set carregando true
            set energiaAtual 100
            set color yellow
          ]

          ;; Se não encontrar carregador em nenhuma das condições, faz o movimento-encontra-carregador
          ifelse (localCarregadorX != 1000 and localCarregadorY != 1000)[
            movimento-procura-carregador
          ]
          [
            if not e-parede?[ movimento-livre ]
          ]
        ]
      ]
    ]
  ]
end

to procura-deposito
  if capAtual >= nCapacidade or not any? patches with [pcolor = red] [

    ifelse ([pcolor] of patch-ahead 1 = green) [
      ifelse e-tapete? [forward 0.25][forward 1]
      set capAtual 0
      set despejando true
    ]
    [
      ifelse(patch-right-and-ahead 90 1 != nobody and [pcolor] of patch-right-and-ahead 90 1 = green) [
        right 90
        ifelse e-tapete? [forward 0.25][forward 1]
        set capAtual 0
        set despejando true
      ]
      [
        ifelse (patch-right-and-ahead -90 1 != nobody and  [pcolor] of patch-right-and-ahead -90 1 = green) [
          left 90
          ifelse e-tapete? [forward 0.25][forward 1]
          set capAtual 0
          set despejando true
        ]
        [
          if (patch-at 0 -1 != nobody and [pcolor] of patch-at 0 -1 = green) [
            right 180
            ifelse e-tapete? [forward 0.25][forward 1]
            set capAtual 0
            set despejando true
          ]
          ;; Se não encontrar carregador em nenhuma das condições, faz o movimento-encontra-carregador
          ifelse (localDepositoX != 1000 and localDepositoY != 1000)
          [
            movimento-procura-Deposito]
          [
            if not e-parede?[ movimento-livre]
          ]
        ]
      ]
    ]
  ]
end

to movimento-procura-deposito
  ask aspiradores [

    ;; Verifica se está na direção correta em relação ao carregador
    ifelse (ycor < LocalDepositoY and heading = 0) or
    (xcor < LocalDepositoX and heading = 90) or
    (ycor > LocalDepositoY and heading = 180) or
    (xcor > LocalDepositoX and heading = 270)
    [
      ;; Verifica se o patch à frente é branco (obstáculo)
      if patch-ahead 1 != nobody and [pcolor] of patch-ahead 1 = white [
        ;; Gira aleatoriamente para encontrar um caminho livre
        let r random 2
        ifelse (r = 0)
        [ right 90 ] ;; Gira à direita
        [ left 90 ]  ;; Gira à esquerda
      ]
      ;; Se o patch à frente não for branco, move-se para frente
      ifelse e-tapete? [forward 0.25][forward 1]
      set energiaAtual energiaAtual - 1
    ]
    [
      ;; Verifica se está alinhado no eixo x ou y em relação ao carregador e se precisa ajustar a direção
      ifelse (ycor = LocalDepositoY and heading = 0 and xcor < LocalDepositoX) or
      (ycor = LocalDepositoY and heading = 180 and xcor > LocalDepositoX) or
      (xcor = LocalDepositoX and heading = 90 and ycor > LocalDepositoY) or
      (xcor = LocalDepositoX and heading = 270 and ycor < LocalDepositoY) or
      (xcor = LocalDepositoX and heading = 0 and ycor > LocalDepositoY)
      [
        ;; Verifica se há obstáculo à frente
        if patch-ahead 1 != nobody and [pcolor] of patch-ahead 1 = white [
          let r random 2
          ifelse (r = 0)
          [ right 90 ]
          [ left 90 ]
        ]
        ;; Gira à direita se o caminho estiver livre
        right 90
      ]
      [
        ;; Verifica se deve girar à esquerda
        ifelse (ycor = LocalDepositoY and heading = 0 and xcor > LocalDepositoX) or
        (ycor = LocalDepositoY and heading = 180 and xcor < LocalDepositoX) or
        (xcor = LocalDepositoX and heading = 90 and ycor < LocalDepositoY) or
        (xcor = LocalDepositoX and heading = 270 and ycor > LocalDepositoY) or
        (xcor = LocalDepositoX and heading = 180 and ycor < LocalDepositoY)
        [
          ;; Verifica se há obstáculo à frente
          if patch-ahead 1 != nobody and [pcolor] of patch-ahead 1 = white [
            let r random 2
            ifelse (r = 0)
            [ right 90 ] ;; Gira à direita
            [ left 90 ]  ;; Gira à esquerda
          ]
          ;; Gira à esquerda se o caminho estiver livre
          left 90
        ]
        [
          ;; Movimentos aleatórios, garantindo que o caminho esteja livre
          if random 100 < 90 [
            if patch-ahead 1 != nobody and [pcolor] of patch-ahead 1 != white[
              ;; Move-se para frente se o caminho estiver livre
              ifelse e-tapete? [forward 0.25][forward 1]
              set energiaAtual energiaAtual - 1
            ]
          ]
          ;; Se não encontrar uma rota, gira aleatoriamente
          ifelse random 100 < 50
          [ right 90 ]
          [ left 90 ]
        ]
      ]
    ]
  ]
end

to verificar-celulas
  if ( patch-here != nobody and [pcolor] of patch-here = blue and localCarregadorX = 1000 and localCarregadorY = 1000  )[
    set localCarregadorX [pxcor] of patch-here
    set localCarregadorY [pycor] of patch-here
  ]
  if ( patch-ahead 1 != nobody and [pcolor] of patch-ahead 1 = blue and localCarregadorX = 1000 and localCarregadorY = 1000  )[
    set localCarregadorX [pxcor] of patch-ahead 1
    set localCarregadorY [pycor] of patch-ahead 1
  ]
  if (patch-right-and-ahead 90 1 != nobody and [pcolor] of patch-right-and-ahead 90 1 = blue and localCarregadorX = 1000 and localCarregadorY = 1000 )[
    set localCarregadorX [pxcor] of patch-right-and-ahead 90 1
    set localCarregadorY [pycor] of patch-right-and-ahead 90 1
  ]
  if (patch-right-and-ahead -90 1 != nobody and [pcolor] of patch-right-and-ahead -90 1 = blue and localCarregadorX = 1000 and localCarregadorY = 1000 )[
    set localCarregadorX [pxcor] of patch-right-and-ahead -90 1
    set localCarregadorY [pycor] of patch-right-and-ahead -90 1
  ]
  if (patch-ahead -1 != nobody and [pcolor] of patch-ahead -1 = blue and localCarregadorX = 1000 and localCarregadorY = 1000)[
    set localCarregadorX [pxcor] of patch-ahead -1
    set localCarregadorY [pycor] of patch-ahead -1
  ]

  if (patch-here != nobody and [pcolor] of patch-here = green and localDepositoX = 1000 and localDepositoY = 1000 )[
    set localDepositoX [pxcor] of patch-here
    set localDepositoY [pycor] of patch-here
  ]

  if (patch-ahead 1 != nobody and [pcolor] of patch-ahead 1 = green and localDepositoX = 1000 and localDepositoY = 1000)[
    set localDepositoX [pxcor] of patch-ahead 1
    set localDepositoY [pycor] of patch-ahead 1
  ]
  if (patch-right-and-ahead 90 1 != nobody and [pcolor] of patch-right-and-ahead 90 1 = green and localDepositoX = 1000 and localDepositoY = 1000 )[
    set localDepositoX [pxcor] of patch-right-and-ahead 90 1
    set localDepositoY [pycor] of patch-right-and-ahead 90 1
  ]
  if (patch-right-and-ahead -90 1 != nobody and [pcolor] of patch-right-and-ahead -90 1 = green and localDepositoX = 1000 and localDepositoY = 1000)[
    set localDepositoX [pxcor] of patch-right-and-ahead -90 1
    set localDepositoY [pycor] of patch-right-and-ahead -90 1
  ]
  if (patch-ahead -1 != nobody and [pcolor] of patch-ahead -1 = green and localDepositoX = 1000 and localDepositoY = 1000)[
    set localDepositoX [pxcor] of patch-ahead -1
    set localDepositoY [pycor] of patch-ahead -1
  ]
end

to-report e-branco?
  let patch-ahead-1 patch-ahead 1 ;pega a patch à frente do agente

  ;; Verifica se o patch à frente do agente é branco ou uma parede
  if patch-ahead-1 != nobody [
    if [pcolor] of patch-ahead 1 = white [
      report true  ;; Retorna true se o patch é branco
    ]
  ]
  report false  ;; Retorna false se o patch não é branco

end

to tempoCarga
  ifelse ticksPCarregar = 0[
    set carregando false
    set ticksPCarregar tCarga
  ]
  [
    set ticksPCarregar ticksPCarregar - 1
  ]

end

to tempoDespejo
  if despejando = true[
    set ticksPDespejar ticksPDespejar - 1

    if ticksPDespejar <= 0 [

      set ticksPDespejar tDespejar
      set despejando false
    ]
  ]
end

to-report e-parede?
  let p patch-ahead 1

  if p = nobody [
    right 180
    report true ; Se não houver patch à frente, significa que está na parede
  ]

  ; Se o patch à frente existir, verificamos suas coordenadas
  ;let px [pxcor] of patch-ahead-1 ; coordenada X do patch à frente
  ;let py [pycor] of patch-ahead-1 ; coordenada Y do patch à frente

  ; Verifica se o patch à frente está fora dos limites de X ou Y
  ;if px > max-pxcor or px < min-pxcor [report true]
  ;if py > max-pycor or py < min-pycor [report true]

  report false ; se não estiver fora dos limites, retorna false
end

to reproduzir
  ; Se a energia do aspirador estiver no máximo, ele pode se reproduzir
  if energiaAtual >= 100 [
    hatch 1 [
      set energiaAtual 50 ; O novo aspirador começa com metade da energia
      set heading 90 ; Novo aspirador começa numa direção aleatória
      setxy random-xcor random-ycor ; Coloca o novo aspirador em uma nova posição aleatória

    ]
    ; Reduz a energia do aspirador original como "custo" da reprodução
    set energiaAtual energiaAtual / 2
  ]
end

to infoNeighbour
  ask aspiradores [
    if localCarregadorX != 1000 and localCarregadorY != 1000[
      let localCarregadorVizinhoX localCarregadorX
      let localCarregadorVizinhoY localCarregadorY

      let neighbours turtles-on neighbors4
      if any? neighbours [
        ask neighbours [
          set localCarregadorX localCarregadorVizinhoX
          set localCarregadorY localCarregadorVizinhoY

        ]
      ]
      let same-position-neighbours turtles-here with [self != myself]
      if any? same-position-neighbours [
        ask same-position-neighbours [
          set localCarregadorX localCarregadorVizinhoX
          set localCarregadorY localCarregadorVizinhoY
        ]
      ]
    ]
  ]
end

to-report e-tapete?
  if pcolor = grey [  ;; Verifica se a cor do patch atual é cinzenta (tapete)
    report true
  ]
  report false
end

to verifica-estragado
  if estragado [
    ifelse movimentos-restantes > 0 [
      ;; Reduz o número de movimentos restantes
      set movimentos-restantes movimentos-restantes - 1
    ] [
      show("Bateria rebentou!")
      ask patch-here [set pcolor white]
      die
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
291
34
794
538
-1
-1
15.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

SLIDER
22
67
132
100
nCarregadores
nCarregadores
0
5
5.0
1
1
NIL
HORIZONTAL

BUTTON
147
24
249
57
GO
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
22
24
131
57
SETUP
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
145
67
249
100
pLixo
pLixo
0
60
40.0
1
1
NIL
HORIZONTAL

SLIDER
22
108
132
141
nAspiradores
nAspiradores
1
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
145
108
248
141
nEnergia
nEnergia
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
24
149
132
182
nCapacidade
nCapacidade
0
100
15.0
1
1
NIL
HORIZONTAL

SLIDER
145
148
248
181
nIrCarregar
nIrCarregar
0
70
65.0
1
1
NIL
HORIZONTAL

SLIDER
25
188
133
221
tDespejar
tDespejar
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
146
188
248
221
tCarga
tCarga
0
100
20.0
1
1
NIL
HORIZONTAL

SWITCH
26
228
133
261
reproducao?
reproducao?
1
1
-1000

SWITCH
147
229
249
262
tapete?
tapete?
1
1
-1000

SWITCH
26
273
132
306
defeitos-aspirador?
defeitos-aspirador?
1
1
-1000

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

ufo top
false
0
Circle -1 true false 15 15 270
Circle -16777216 false false 15 15 270
Circle -7500403 true true 75 75 150
Circle -16777216 false false 75 75 150
Circle -7500403 true true 60 60 30
Circle -7500403 true true 135 30 30
Circle -7500403 true true 210 60 30
Circle -7500403 true true 240 135 30
Circle -7500403 true true 210 210 30
Circle -7500403 true true 135 240 30
Circle -7500403 true true 60 210 30
Circle -7500403 true true 30 135 30
Circle -16777216 false false 30 135 30
Circle -16777216 false false 60 210 30
Circle -16777216 false false 135 240 30
Circle -16777216 false false 210 210 30
Circle -16777216 false false 240 135 30
Circle -16777216 false false 210 60 30
Circle -16777216 false false 135 30 30
Circle -16777216 false false 60 60 30

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="nCapacidade">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproducao?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nCarregadores">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pLixo">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tapete?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tCarga">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nIrCarregar">
      <value value="65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tDespejar">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nEnergia">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nAspiradores">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defeitos-aspirador?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experimento_vAgentes" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="nAspiradores">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pLixo">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nEnergia">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nIrCarregar">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nCarregadores">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nCapacidade">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tCarga">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tDespejar">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defeitos-aspirador?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproducao?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tapete?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
