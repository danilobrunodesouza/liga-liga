# Liga-Liga na Lousa (16:9 / 1920x1080)

- Background: res://assets/backgrounds/chalkboard.png (1920x1080)
- Fonte: res://assets/fonts/chawp.ttf
- Dados: res://data/ligaliga.json

## Como jogar
1) Clique em uma opção da esquerda
2) Clique em uma opção da direita
- Correto: borda verde por 1s; depois 50% opacidade e trava o par
- Errado: borda vermelha por 1s; depois volta ao normal

## Ajustar SafeArea
No scripts/main.gd, método `_setup_safe_area()`
