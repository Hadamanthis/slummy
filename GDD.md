# GDD — Slime Elástico

## 1. Visão geral

**Título provisório:** Slime Elástico
**Gênero:** Arcade 2D / física simples / casual mobile
**Plataformas-alvo:** Web/HTML5 para itch.io, Windows e Android futuramente
**Engine:** Godot 4.x
**Controle principal:** arrastar e soltar
**Duração média de partida:** 30 segundos a 3 minutos
**Objetivo de desenvolvimento:** criar um jogo pequeno, polido e terminável, com uma mecânica central clara e reutilizável para aprender física, input, colisões e game feel na Godot.

## 2. Fantasia do jogador

O jogador controla um slime saltitante em uma pequena arena. Para mover o slime, ele precisa puxá-lo como se fosse uma borracha e soltá-lo. O slime é lançado, quica nas paredes e tenta coletar frutas enquanto evita espinhos.

A sensação desejada é parecida com brincar com um estilingue: puxar, mirar, soltar e ver o resultado físico acontecer.

## 3. Core loop

1. O slime está parado ou quase parado.
2. O jogador clica/toca no slime.
3. O jogador arrasta para trás para definir direção e força.
4. O jogador solta.
5. O slime é lançado pela arena.
6. O slime quica, coleta fruta ou bate em perigo.
7. Quando o slime perde velocidade, o lançamento termina.
8. A pontuação do lançamento é calculada com base em quantas frutas foram coletadas antes do slime parar.
9. O jogador precisa coletar todas as frutas antes de acabar o limite de lançamentos da fase.
10. Se todas as frutas da fase foram coletadas, o jogo avança para a próxima fase manual.
11. Se os lançamentos acabam com frutas restantes, a fase falha.
12. Se o slime encostar em um espinho, a partida acaba.

Nota de protótipo atual:

O projeto está testando uma versão mais tática/puzzle do core loop, com fases manuais, várias frutas por fase e limite de lançamentos. A hipótese atual é que a limitação de tentativas cria uma motivação mais forte do que apenas acumular pontos.

## 4. Objetivo do jogador

O objetivo principal em teste é **coletar todas as frutas da fase usando poucos lançamentos e sem tocar nos espinhos**.

O jogo pode evoluir para score attack depois, mas o protótipo atual está mais próximo de um puzzle arcade de fases curtas: tentativa rápida, erro compreensível e vontade de tentar uma rota melhor.

## 5. Mecânica principal

### 5.1 Arrastar e soltar

O jogador só pode lançar o slime quando ele estiver em estado de repouso ou quase repouso.

Ao clicar/tocar no slime:

* o jogo entra no estado de mira;
* o slime não é lançado ainda;
* uma seta ou linha mostra a direção e a força do lançamento.

Ao arrastar:

* quanto maior a distância entre o slime e o dedo/mouse, maior a força;
* existe um limite máximo de força;
* a direção do lançamento é oposta ao arrasto, como um estilingue.

Ao soltar:

* o slime recebe um impulso;
* a seta desaparece;
* o slime entra no estado de movimento;
* o jogador precisa esperar ele desacelerar para lançar novamente.

### 5.2 Movimento do slime

O slime deve se comportar como uma bolinha elástica.

Propriedades sugeridas:

* quica nas paredes;
* perde um pouco de velocidade ao longo do tempo;
* não deve ficar quicando infinitamente;
* deve parar ou quase parar depois de alguns segundos;
* pode ter limite máximo de velocidade para evitar bugs.

Na Godot, o slime pode ser implementado de duas formas:

**Opção A — RigidBody2D:**
Mais física real, mas menos controle fino.

**Opção B — CharacterBody2D com física fake:**
Mais previsível para iniciante. O jogo controla velocity, bounce e desaceleração manualmente.

Para este projeto, a recomendação é usar **CharacterBody2D com física fake**, porque facilita ajustar a sensação do movimento.

## 6. Estados do slime

O slime terá três estados principais:

### Idle

O slime está parado e pode ser puxado.

Condições:

* velocidade baixa;
* jogador pode iniciar arrasto;
* animação de slime respirando/parado.

### Aiming

O jogador está segurando e arrastando.

Condições:

* mostrar linha/seta de mira;
* slime pode esticar visualmente;
* tempo do jogo continua normal;
* nenhum impulso foi aplicado ainda.

### Moving

O slime foi lançado.

Condições:

* não pode ser puxado novamente;
* colisões com paredes, frutas e espinhos estão ativas;
* quando a velocidade cair abaixo de um valor mínimo, volta para Idle.

## 7. Regras principais

### 7.1 Coleta de fruta

Quando o slime encosta na fruta:

* soma 1 ponto;
* toca som de coleta;
* gera partícula simples;
* fruta desaparece;
* nova fruta aparece em outro ponto da arena.

A nova fruta não pode nascer:

* dentro do slime;
* em cima de um espinho;
* colada demais na parede;
* em posição impossível de alcançar.

### 7.2 Espinhos

Se o slime encostar em um espinho:

* tocar som de erro;
* pausar brevemente ou aplicar slow motion curto;
* tremer a tela;
* ir para game over.

Na primeira versão, basta um único espinho fixo ou aleatório.

### 7.3 Pontuação

Pontuação básica planejada inicialmente:

* +1 por fruta coletada.

Regra em teste no protótipo atual:

* contar quantas frutas foram coletadas durante o mesmo lançamento;
* calcular a pontuação quando o slime parar;
* usar `frutas_coletadas_no_lancamento ** 2`.

Exemplos:

* 1 fruta no lançamento: 1 ponto;
* 2 frutas no lançamento: 4 pontos;
* 3 frutas no lançamento: 9 pontos.

Motivo de design:

Essa regra recompensa planejamento, ricochete e controle de força. Ela também pode deixar o jogo menos interessante se o jogador não entender a pontuação ou se as fases não criarem escolhas claras. Por isso, ainda é uma hipótese de protótipo, não uma regra final.

Limitação principal em teste:

* cada fase tem um número máximo de lançamentos;
* cada lançamento consome uma tentativa;
* coletar todas as frutas vence a fase;
* acabar os lançamentos com frutas restantes falha a fase.

Motivo de design:

Pontuação sozinha não cria pressão se o jogador pode tentar infinitamente. O limite de lançamentos transforma cada fase em um problema pequeno: escolher entre um lançamento seguro, um lançamento eficiente ou um lançamento arriscado.

Pontuação extra opcional futura:

* combo por coletar frutas em poucos lançamentos;
* bônus por sequência sem bater em parede.

Para o MVP, manter a regra que deixar o core loop mais claro e divertido nos testes manuais.

### 7.4 Game over

A partida termina quando:

* o slime toca em um espinho.

Na tela de game over, mostrar:

* pontuação final;
* melhor pontuação local;
* botão de tentar novamente;
* botão de voltar ao menu, se existir menu.

## 8. Progressão de dificuldade

A dificuldade deve aumentar de forma simples.

Modelo recomendado:

* 0 a 4 pontos: 1 espinho.
* 5 a 9 pontos: 2 espinhos.
* 10 a 14 pontos: 3 espinhos.
* 15+ pontos: espinhos começam a mudar de posição depois de cada coleta.

Alternativas de dificuldade:

* reduzir tamanho da fruta;
* aumentar quantidade de espinhos;
* adicionar paredes internas;
* criar frutas que somem após alguns segundos;
* adicionar espinho móvel.

Para a primeira versão, usar apenas:

* aumentar número de espinhos conforme a pontuação.

## 9. Arena

A arena deve ser pequena e fechada.

Características:

* formato retangular;
* paredes com colisão;
* slime quica nas paredes;
* espaço suficiente para mirar e calcular lançamentos;
* visual limpo.

Formato sugerido para mobile:

* tela vertical;
* arena ocupando a maior parte da tela;
* UI no topo com pontuação e recorde.

Exemplo de layout:

* topo: pontuação atual e recorde;
* centro: arena;
* slime começa no centro ou parte inferior;
* fruta aparece em posição aleatória;
* espinhos espalhados.

## 10. Controles

### PC/Web

* clicar no slime;
* arrastar com mouse;
* soltar para lançar.

### Mobile

* tocar no slime;
* arrastar;
* soltar.

### Regras de input

O jogador só pode começar o arrasto se:

* tocar próximo do slime;
* o slime estiver em Idle.

Se o jogador tocar longe do slime, nada acontece.

## 11. Interface

### Durante o jogo

Elementos mínimos:

* pontuação atual;
* melhor pontuação;
* seta/linha de mira durante o arrasto;
* indicador visual de força.

Elementos opcionais:

* contador de lançamentos;
* combo;
* aviso de nova dificuldade;
* efeito na borda quando perto do perigo.

### Tela inicial

MVP pode não ter tela inicial. O jogo pode começar direto.

Versão polida deve ter:

* título;
* botão jogar;
* instrução curta: “Puxe, mire e solte.”

### Tela de game over

Mostrar:

* “Fim de jogo”;
* pontuação;
* recorde;
* botão “Tentar novamente”.

## 12. Visual

O visual deve ser simples, colorido e legível.

### Estilo sugerido

* cartoon simples;
* slime redondo e expressivo;
* fundo limpo;
* frutas com cores fortes;
* espinhos bem visíveis.

### Elementos visuais mínimos

* slime;
* fruta;
* espinho;
* paredes;
* linha de mira;
* partículas simples.

### Animações importantes

* slime estica ao puxar;
* slime comprime ao bater na parede;
* fruta pulsa levemente;
* espinho fica estático, mas com brilho/perigo;
* tela treme ao morrer.

## 13. Áudio

Áudio é importante para deixar o jogo satisfatório.

### Sons mínimos

* puxar/esticar;
* soltar;
* quicar na parede;
* coletar fruta;
* morrer no espinho;
* botão de UI.

### Música

Para o MVP, música é opcional.

Se usar música:

* loop curto;
* leve;
* sem atrapalhar;
* idealmente com ritmo casual.

## 14. Game feel

O jogo depende muito do game feel. O movimento precisa parecer gostoso.

Prioridades de polimento:

1. Lançamento responsivo.
2. Linha de mira clara.
3. Slime com squash/stretch.
4. Som de “boing” ao quicar.
5. Partícula ao coletar.
6. Pequeno screen shake ao bater forte.
7. Game over com impacto.

Mesmo com gráficos simples, esses elementos fazem o protótipo parecer mais acabado.

## 15. Estrutura de cenas na Godot

Sugestão de estrutura:

```text
res://
  scenes/
    Main.tscn
    Slime.tscn
    Fruit.tscn
    Spike.tscn
    Arena.tscn
    UI.tscn

  scripts/
    main.gd
    slime.gd
    fruit.gd
    spike.gd
    arena.gd
    ui.gd

  assets/
    sprites/
    sounds/
    particles/
```

### Main.tscn

Responsável por:

* iniciar partida;
* controlar pontuação;
* carregar fases manuais;
* conectar sinais de frutas, espinhos e slime;
* detectar game over;
* reiniciar jogo.

### Level.tscn

Cada fase manual usa o script comum `scripts/level.gd`.

Responsável por guardar dados configuráveis da fase:

* quantidade máxima de lançamentos;
* posição inicial do slime por meio de `SlimeStart`;
* composição manual de frutas, espinhos e arena.

A fase guarda dados e composição. O `Main` continua decidindo regra de jogo,
vitória, derrota, pontuação e troca de fase.

### Slime.tscn

Nós sugeridos:

```text
Slime (CharacterBody2D)
  Sprite2D
  CollisionShape2D
  Area2D
    CollisionShape2D
  Line2D
```

Responsável por:

* input de arrastar;
* calcular força;
* aplicar velocidade;
* quicar;
* detectar repouso;
* emitir sinais.

### Fruit.tscn

Nós sugeridos:

```text
Fruit (Area2D)
  Sprite2D
  CollisionShape2D
```

Responsável por:

* detectar coleta;
* emitir sinal collected.

### Spike.tscn

Nós sugeridos:

```text
Spike (Area2D)
  Sprite2D
  CollisionShape2D
```

Responsável por:

* detectar colisão fatal;
* emitir sinal hit_player.

### UI.tscn

Responsável por:

* atualizar pontuação;
* mostrar recorde;
* mostrar game over.

## 16. Sinais sugeridos

### Slime

```text
launched
stopped
```

### Fruit

```text
collected
```

### Main

Recebe sinais e decide:

* somar ponto;
* calcular pontuação quando o slime para;
* trocar de fase quando todas as frutas forem coletadas;
* encerrar partida.

## 17. Variáveis principais

### Slime

```text
state
velocity
drag_start_position
drag_current_position
max_drag_distance
launch_force_multiplier
friction
bounce_factor
min_stop_speed
max_speed
```

### Game Manager / Main

```text
score
best_score
current_fruit
spikes
game_state
difficulty_level
arena_bounds
```

## 18. Fórmula base do lançamento

Direção do lançamento:

```text
launch_vector = slime_position - drag_position
```

Força:

```text
force = clamp(length(launch_vector), 0, max_drag_distance)
```

Velocidade aplicada:

```text
velocity = normalized(launch_vector) * force * launch_force_multiplier
```

A lógica é:

* se o jogador puxa para baixo, o slime vai para cima;
* se puxa para esquerda, o slime vai para direita;
* quanto mais puxa, mais forte.

## 19. Colisão e quique

Se usar CharacterBody2D, o slime pode mover com `move_and_collide`.

Ao colidir com parede:

```text
velocity = velocity.bounce(collision_normal) * bounce_factor
```

Depois, aplicar desaceleração:

```text
velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
```

Quando a velocidade for baixa:

```text
if velocity.length() < min_stop_speed:
    velocity = Vector2.ZERO
    state = Idle
```

## 20. MVP

O MVP deve conter apenas o necessário para o jogo funcionar.

### MVP obrigatório

* slime controlável por arrastar e soltar;
* arena com paredes;
* slime quicando nas paredes;
* uma fruta coletável;
* um espinho perigoso;
* pontuação;
* game over;
* reiniciar partida.

### Fora do MVP

Não fazer no começo:

* loja;
* upgrades;
* skins;
* fases;
* vários tipos de fruta;
* vários tipos de slime;
* história;
* chefes;
* menus complexos;
* ranking online.

## 21. Versão itch.io

Para uma versão publicável simples, adicionar:

* tela inicial;
* tela de game over;
* recorde salvo localmente;
* 3 a 5 sons;
* partículas simples;
* animações básicas;
* dificuldade progressiva;
* instrução visual no começo;
* export HTML5.

## 22. Roadmap de desenvolvimento

### Etapa 1 — Movimento básico

* Criar arena.
* Criar slime.
* Implementar arrastar.
* Implementar soltar.
* Slime se move.
* Slime desacelera.

Critério de conclusão:

* o jogador consegue lançar o slime repetidamente.

### Etapa 2 — Colisão e quique

* Adicionar paredes.
* Fazer slime quicar.
* Ajustar bounce e friction.
* Impedir movimento infinito.

Critério de conclusão:

* slime bate nas paredes, quica e eventualmente para.

### Etapa 3 — Coleta

* Criar fruta.
* Detectar colisão slime/fruta.
* Somar ponto.
* Spawnar nova fruta.

Critério de conclusão:

* jogador consegue fazer pontos.

### Etapa 4 — Perigo

* Criar espinho.
* Detectar colisão slime/espinho.
* Implementar game over.
* Criar restart.

Critério de conclusão:

* partida tem risco e fim.

### Etapa 5 — Dificuldade

* Adicionar mais espinhos por pontuação.
* Impedir spawn injusto.
* Testar ritmo da partida.

Critério de conclusão:

* partida fica progressivamente mais difícil.

### Etapa 6 — Polimento

* Linha de mira.
* Squash/stretch no slime.
* Sons.
* Partículas.
* Screen shake.
* UI final.

Critério de conclusão:

* jogo parece intencional e agradável.

### Etapa 7 — Publicação

* Exportar para HTML5.
* Criar página no itch.io.
* Adicionar descrição curta.
* Adicionar screenshots.
* Publicar versão 0.1.

## 23. Critérios para saber se o protótipo funciona

O protótipo está funcionando se:

* lançar o slime já é divertido mesmo sem arte;
* o jogador entende o que fazer sem tutorial longo;
* uma partida termina rápido;
* perder dá vontade de tentar de novo;
* coletar fruta gera satisfação;
* o jogador sente que errou por falta de mira, não por injustiça.

Se o jogo só parecer interessante depois de “colocar muita coisa”, o core loop ainda não está bom.

## 24. Riscos do projeto

### Risco 1 — Física ruim

Se o slime parecer leve demais, pesado demais ou aleatório demais, o jogo fica frustrante.

Solução:

* usar física fake com CharacterBody2D;
* limitar velocidade máxima;
* controlar bounce e friction manualmente.

### Risco 2 — Spawn injusto

Fruta pode nascer perto demais de espinhos ou em lugar ruim.

Solução:

* validar posição antes de spawnar;
* usar distância mínima de perigos;
* evitar bordas.

### Risco 3 — Jogo vazio

Se for só coletar fruta sem variação, pode cansar rápido.

Solução:

* adicionar dificuldade progressiva;
* usar combos;
* criar variações simples de arena depois do MVP.

### Risco 4 — Escopo crescer

Adicionar fases, skins, loja, upgrades e inimigos pode impedir a conclusão.

Solução:

* terminar primeiro a versão score attack;
* só adicionar conteúdo depois de ter uma build jogável.

## 25. Possíveis expansões futuras

Somente depois do MVP:

### Modo fases

Cada fase tem:

* posição inicial;
* fruta ou alvo;
* espinhos;
* número máximo de lançamentos.

### Frutas especiais

* fruta dourada: vale mais pontos;
* fruta temporária: some rápido;
* fruta pesada: precisa bater mais forte.

### Obstáculos

* molas;
* paredes móveis;
* portais;
* lama que reduz velocidade;
* ventiladores que empurram.

### Customização

* cores do slime;
* chapéus;
* expressões faciais.

### Modo desafio diário

Uma arena gerada por seed, igual para todos no dia.

## 26. Escopo recomendado final

Para a primeira versão pública, o jogo deve ter:

* uma arena;
* slime com lançamento elástico;
* frutas aleatórias;
* espinhos progressivos;
* pontuação;
* recorde local;
* tela inicial;
* tela de game over;
* sons simples;
* partículas;
* export HTML5.

Nada além disso.

## 27. Frase de venda

“Puxe, solte e faça seu slime quicar pela arena para coletar frutas sem cair nos espinhos.”

## 28. Resumo do projeto

Slime Elástico é um arcade 2D casual baseado em arrastar e soltar. O jogador lança um slime elástico por uma arena fechada, coletando frutas e evitando espinhos. O jogo tem partidas curtas, dificuldade crescente e foco em sensação física agradável. O projeto é pequeno o suficiente para um iniciante concluir, mas ensina mecânicas importantes da Godot, como input, colisão, estados, física fake, UI, sinais, spawn e polimento.
