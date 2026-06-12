# Aprendizados de Desenvolvimento de Jogos

Este arquivo registra conceitos importantes aprendidos durante o desenvolvimento. A ideia nao e documentar cada clique da Godot, mas guardar principios que vale treinar de novo em outros sistemas e projetos.

## 1. Separar regra, dado e visual

Um mesmo elemento do jogo pode ter partes diferentes:

- dado: informacao configuravel, como `IngredientData`, `RecipeData` e `CustomerData`;
- runtime: estado vivo da partida, como paciencia atual do cliente ou ingredientes dentro do caldeirao;
- visual: como esse estado aparece para o jogador.

Essa separacao evita que a interface vire dona da regra e facilita trocar arte, texto ou layout sem reescrever gameplay.

## 2. Composicao antes de sistemas globais

Antes de criar managers globais, autoloads ou sistemas grandes, preferimos cenas pequenas com responsabilidades claras.

Exemplos:

- `Cauldron` controla regra do caldeirao;
- `Customer` controla estado vivo do cliente;
- `CustomerView` desenha o cliente;
- `IngredientCard` representa uma carta clicavel;
- `IngredientHand` organiza varias cartas.

Isso reduz acoplamento e torna cada parte mais facil de testar manualmente.

## 3. Cena reutilizavel deve receber dados

Uma carta de ingrediente nao deve ter "Erva Verde" escrito fixo no script. Ela recebe um `IngredientData` e se atualiza.

Esse padrao permite adicionar novo conteudo criando ou editando Resources, nao duplicando codigo.

## 4. O emissor de um evento nao precisa saber quem reage

Sinais sao uma forma de aplicar o padrao Observer.

Uma carta emite `ingredient_selected`. Ela nao precisa conhecer o caldeirao, a receita ou a cena principal. Quem escuta decide o que fazer.

Isso mantem os componentes independentes.

## 5. Estado explicito evita bugs invisiveis

O caldeirao usa estados como `EMPTY`, `RECEIVING_INGREDIENTS` e `POTION_READY`.

Isso e melhor do que depender de varias flags soltas, porque cada acao pode validar claramente se e permitida naquele estado.

Quando existir uma lista, como ingredientes no caldeirao, ela pode ajudar a validar o estado, mas nao deve substituir o estado principal sem criterio.

## 6. Layout visual e comportamento sao responsabilidades diferentes

`IngredientHand` calcula onde as cartas ficam.

`IngredientCard` sabe como uma carta reage ao mouse.

Esse corte e importante: a mao nao precisa saber detalhes de hover, e a carta nao precisa saber quantas cartas existem.

## 7. Layout procedural e melhor que posicionamento manual repetido

Para uma mao de cartas, a posicao e rotacao devem depender da quantidade de cartas.

A ideia central:

- calcular o centro da mao;
- descobrir o deslocamento de cada carta em relacao ao centro;
- usar esse deslocamento para definir posicao, rotacao e profundidade visual.

Isso permite que a mao funcione com 3, 5 ou 10 cartas sem reposicionar tudo manualmente.

## 8. Separar hitbox de visual animado

Quando a carta subia no hover, a area clicavel tambem subia. O mouse saia da carta, disparava `mouse_exited`, e a carta piscava.

A solucao foi deixar o no interativo parado e mover apenas um filho visual, como `VisualRoot`.

Principio:

- hitbox/input deve ser estavel;
- visual pode animar livremente;
- o jogador sente movimento, mas o sistema de input nao fica instavel.

Esse padrao aparece em botoes, cartas, inimigos, pickups e menus animados.

## 9. Usar escala com cuidado em UI

Escala e boa para animacao momentanea, como hover ou feedback.

Para layout estavel, preferimos tamanho real, `custom_minimum_size`, anchors, containers e posicoes controladas.

Se a UI e desenhada gigante e reduzida com `scale`, texto, hitbox, pivots e filhos podem ficar dificeis de prever.

## 10. Placeholder bom ocupa o papel do asset final

Um placeholder nao precisa ser bonito, mas precisa testar o papel correto:

- icone deve ocupar o espaco que o icone final ocuparia;
- retrato deve ter proporcao parecida com o retrato final;
- fundo deve deixar areas livres para a gameplay;
- carta deve testar leitura, tamanho e interacao.

Placeholder ruim pode esconder problemas de layout.

## 11. Visual de jogo precisa de hierarquia

A tela nao deve parecer uma lista de controles. O jogador precisa perceber rapidamente:

- quem esta pedindo;
- onde esta o caldeirao;
- quais ingredientes pode escolher;
- qual foi o resultado da acao;
- qual e o estado da loja.

Arte, layout, tamanho e contraste devem guiar o olhar para o que importa.

## 12. Polimento deve confirmar a acao do jogador

Hover, brilho, som, shake, cor e animacao nao sao decoracao quando ajudam o jogador a entender que algo aconteceu.

Bom feedback responde perguntas como:

- cliquei?
- a acao funcionou?
- por que nao funcionou?
- qual elemento mudou?

Polimento bom reduz confusao.

## 13. Refatorar quando a dor aparece

Nem toda ideia precisa virar sistema imediatamente.

Mas quando uma responsabilidade comeca a se repetir, ficar confusa ou atrapalhar evolucao, e hora de extrair.

Foi o caso de:

- caldeirao virar componente proprio;
- cliente separar dado, runtime e visual;
- ingredientes virarem cartas;
- mao de cartas ganhar layout procedural.

## 14. Pensar no futuro sem implementar tudo agora

Podemos desenhar espaco para varios clientes, eventos e cartas extras sem implementar todos esses sistemas imediatamente.

Isso e diferente de overengineering:

- preparar layout para expansao e bom;
- criar managers sem necessidade ainda e cedo demais.

O projeto deve crescer em camadas jogaveis.

## 15. Sistemas pequenos ainda podem ser trabalhosos

Uma mao de cartas parece uma parte pequena da interface, mas envolve varios problemas reais:

- layout procedural;
- responsividade;
- ordem visual;
- hover;
- hitbox;
- legibilidade;
- textura, filtro e rotacao;
- assets com centro visual diferente do centro matematico.

Isso e normal em desenvolvimento de jogos. Muitas features simples para o jogador sao trabalhosas para o desenvolvedor porque precisam parecer naturais.

O cuidado importante e nao transformar dificuldade em sinal de fracasso. Quando uma parte parece grande demais, reduzimos o objetivo para um comportamento pequeno e verificavel.

## 16. Existem solucoes com custos diferentes

Para cartas, havia varios caminhos possiveis:

- botao simples com texto: rapido, mas com pouca cara de jogo;
- carta como imagem unica: muito simples visualmente, mas pouco flexivel para dados dinamicos;
- carta composta por frame, icone e texto: mais trabalhosa, mas reutilizavel e data-driven;
- sistema completo de cartas com arte unica, texto customizado e animacoes: melhor para jogo de cartas dedicado, mas caro cedo demais.

A melhor escolha depende do escopo. Neste projeto, a carta composta ensina bons principios sem exigir arte final para cada carta.

## 17. Centro visual nem sempre e centro matematico

Um `TextureRect` pode estar centralizado corretamente e ainda assim o desenho parecer torto.

Isso acontece quando o PNG tem:

- padding transparente desigual;
- objeto desenhado deslocado;
- silhueta assimetrica;
- sombra ou detalhes que pesam mais de um lado.

Antes de culpar o layout, vale verificar se o asset esta visualmente centralizado. Em jogos, muitas vezes ajustamos cada icone com um pequeno offset artistico.

## 18. Input em UI depende da area real dos Controls

Quando um objeto visual nao clica, a causa pode estar fora dele.

Possiveis causas:

- o `Button` nao cobre a area que o jogador esta clicando;
- um filho visual captura mouse sem precisar;
- um irmao grande esta por cima na ordem visual;
- um `Container` controla tamanho/posicao de forma diferente do esperado;
- `Mouse Filter` esta como `Stop` ou `Pass` onde deveria ser `Ignore`.

Um caso importante foi o `IngredientHandCenter`: ele estava com comportamento de mouse que propagava para o pai, mas isso nao ajudava o clique chegar ao irmao `CauldronButton`.

Principio:

- elementos clicaveis usam `Mouse Filter: Stop`;
- elementos puramente visuais usam `Ignore`;
- areas organizadoras ou decorativas geralmente tambem usam `Ignore`;
- em telas com objetos sobrepostos, sempre conferir a area real dos `Control`.

## 19. Cenas Godot podem juntar comportamento e visual

No inicio, separar `Cauldron` logico de `CauldronArea` visual ajudou a validar regra sem mexer na interface.

Com a evolucao do jogo, o caldeirao deixou de ser apenas regra e virou objeto interativo do mundo. Por isso, a direcao decidida e transformar o caldeirao em uma cena mais completa:

```text
Cauldron
├── visual
├── area clicavel
├── feedback visual
└── regra de ingredientes/mistura
```

Isso combina com a filosofia da Godot de usar cenas como unidades de composicao.

A regra continua importante:

- o visual nao deve decidir receita;
- a UI nao deve manipular listas internas diretamente;
- a cena do caldeirao pode expor metodos claros como `add_ingredient`, `mix`, `clear`, `can_mix`;
- efeitos visuais e clique podem viver junto do objeto, desde que nao confundam responsabilidade.

Essa mudanca deve ser feita quando o fluxo atual estiver validado, para evitar refatorar enquanto o comportamento basico ainda esta instavel.

## 20. Objeto clicavel precisa comunicar affordance

Quando trocamos botoes de UI por objetos do mundo, o jogador precisa perceber que aquilo pode ser clicado.

Um objeto clicavel pode comunicar isso com:

- hover;
- brilho;
- leve movimento idle;
- cursor ou mudanca visual ao passar o mouse;
- contorno/destaque;
- feedback imediato ao clicar.

Se um objeto aparece parado como parte do cenario, ele tende a parecer decoracao. Em jogos, interacao precisa ser visualmente convidativa.

O ideal e comecar simples:

- objeto aparece;
- objeto tem hover;
- objeto responde ao clique;
- depois ganha animacao/tween.

Isso evita polir uma interacao antes de validar se ela funciona no fluxo do jogo.

## 21. Padronizar interacao antes de duplicar polimento

Quando varios objetos do cenario comecam a ter hover, clique, brilho e animacao, copiar o mesmo comportamento em cada script cria inconsistencia.

Exemplos do projeto:

- cartas de ingrediente;
- pocao pronta;
- caldeirao clicavel;
- futuros clientes clicaveis ou alvos de drag-and-drop.

Antes de espalhar tweens e estados visuais, vale definir um padrao comum:

- um root estavel para hitbox/input;
- um `VisualRoot` que pode mover, escalar ou animar;
- filhos visuais com `Mouse Filter: Ignore`;
- feedback consistente para hover;
- feedback consistente para clique;
- nomes iguais quando o padrao se repetir.

Isso nao significa criar uma heranca complexa cedo demais. Podemos comecar copiando a mesma estrutura de cena e, quando a repeticao ficar clara, extrair um componente/base reutilizavel.

Principio: primeiro estabilizar o padrao, depois abstrair.

## 22. Outline por shader e uma ferramenta importante de polimento

Para objetos clicaveis no cenario, como caldeirao, pocao e futuros alvos de entrega, uma borda baseada no formato do sprite comunica melhor a interacao do que uma borda retangular.

Existem dois caminhos:

- duplicar o sprite atras, aplicar uma cor flat e aumentar levemente a escala;
- usar um shader de outline que le o alpha da textura e desenha contorno ao redor do objeto.

O shader e o caminho mais profissional para contorno preciso, mas tambem exige aprender materiais, shaders 2D e leitura de alpha.

Esse estudo fica registrado como topico futuro:

- `ShaderMaterial`;
- `CanvasItem` shader;
- outline baseado em alpha;
- hover visual para objetos clicaveis;
- diferenca entre glow, silhouette e outline.

Para o prototipo, podemos usar glow simples. Para polimento, vale aprender outline por shader.

## 23. Estado do mundo precisa de fonte da verdade

Em jogos, muitos bugs aparecem quando a mesma informacao fica espalhada em varios lugares.

Exemplo generico:

- uma regra diz que uma pocao esta pronta;
- um botao visual tambem guarda se a pocao esta pronta;
- um painel decide sozinho se pode entregar;
- outro sistema limpa o estado por conta propria.

Isso cria estados contraditorios.

Principio: escolha uma fonte da verdade para cada parte importante do mundo.

Exemplos:

- o inventario decide quais itens existem;
- a entidade decide se esta viva ou ativa;
- a maquina de estado decide em qual fase um objeto esta;
- a UI apenas reflete esse estado.

Quando a UI precisa mudar, prefira uma funcao de sincronizacao clara:

```text
estado do jogo -> atualiza visual
```

Em vez de espalhar `visible = true/false`, `disabled = true/false` ou textos por varias funcoes sem criterio.

## 24. Maquinas de estado devem ser pequenas e explicitas

Uma maquina de estado ajuda quando um objeto tem fases claras e acoes permitidas dependem da fase atual.

Bom uso:

```text
EMPTY -> RECEIVING -> READY
```

Mau uso:

```text
var is_empty
var is_ready
var has_been_used
var can_deliver
var was_cleaned
```

Muitas flags podem criar combinacoes impossiveis, como "vazio e pronto ao mesmo tempo".

Boas praticas:

- nomear estados pelo significado de gameplay;
- centralizar transicoes em funcoes claras;
- validar acoes antes de mudar estado;
- emitir eventos/sinais quando o estado muda;
- evitar que sistemas externos alterem estado interno diretamente;
- manter estados derivados fora da maquina quando puderem ser calculados.

Pergunta util: "isso precisa ser armazenado como estado, ou pode ser derivado do estado atual?"

## 25. Regras espalhadas indicam hora de revisar arquitetura

Quando uma regra aparece em muitos lugares, o codigo comeca a ficar fragil.

Sinais de alerta:

- a mesma condicao e checada em varias funcoes;
- a UI decide regra de gameplay;
- objetos externos mexem diretamente em listas internas;
- varias funcoes precisam lembrar de atualizar o mesmo visual;
- consertar um bug exige procurar em muitos scripts;
- uma acao simples tem efeitos colaterais escondidos.

Possiveis solucoes:

- criar uma funcao `can_*` para regras de permissao;
- concentrar transicoes em uma entidade;
- expor metodos publicos claros e esconder detalhes internos;
- usar sinais para avisar mudancas;
- criar uma funcao unica de sincronizacao visual;
- extrair uma cena/componente quando a responsabilidade ficou grande.

O objetivo nao e criar arquitetura grande. O objetivo e reduzir lugares onde uma regra pode ficar inconsistente.

## 26. UI deve refletir regra, nao possuir regra

Interface pode mostrar, destacar, animar e bloquear acoes para ajudar o jogador.

Mas a decisao final deve ficar na regra de jogo.

Exemplo generico:

```text
Botao desabilitado ajuda o jogador.
Funcao `can_perform_action()` protege a regra.
```

Mesmo que a UI esconda um botao, a regra ainda deve validar a acao caso ela seja chamada por outro caminho.

Isso evita bugs quando o controle muda de botao para clique em objeto, atalho de teclado, drag-and-drop ou tutorial.

## 27. Camera e gravidade mudam o escopo do jogo

Antes de implementar movimento, vale decidir se o jogo e visto de cima ou de lado.

Visao de cima tende a favorecer:

- arena fechada;
- mira em 360 graus;
- quique em paredes;
- leitura simples de trajetoria;
- fisica fake sem gravidade.

Visao lateral tende a favorecer:

- plataforma;
- arco com gravidade;
- queda;
- chao e teto com significados diferentes;
- mais regras fisicas para ajustar.

A escolha nao e apenas visual. Ela define quais problemas tecnicos e de design
o prototipo vai precisar resolver.

## 28. Fases manuais ajudam a validar desafios de mira

Quando o jogo depende de precisao, fases manuais sao uma boa primeira etapa.

Elas permitem criar situacoes com intencao clara:

- alvo em linha reta;
- alvo que incentiva ricochete;
- perigo que pune excesso de forca;
- recompensa por planejar melhor o lancamento.

Geracao procedural pode ser util depois, mas no inicio pode esconder se o
problema esta na mecanica, no spawn ou no desenho do desafio.

## 29. Bonus deve reforcar a habilidade principal

Um bonus e bom quando incentiva o jogador a fazer melhor aquilo que o jogo ja
pede.

Neste projeto, coletar varias frutas em um unico lancamento combina com a
mecanica principal porque recompensa:

- mirar melhor;
- prever ricochetes;
- controlar forca;
- entender a arena.

Esse tipo de bonus deve vir depois do loop basico, porque primeiro precisamos
saber se lancar, quicar e coletar uma fruta ja e divertido.

## 30. O jogador pode ser persistente e a fase pode trocar ao redor dele

Em jogos com fases pequenas, nem sempre o jogador precisa estar dentro da cena
da fase.

Uma separacao util:

- `Main` mantem o jogador e controla o fluxo;
- `Level` guarda a composicao espacial da fase;
- `SlimeStart` define onde o jogador nasce naquela fase.

Assim, trocar de fase nao exige criar um novo jogador. O jogo apenas carrega
outra composicao e reposiciona o objeto controlavel.

Esse padrao ajuda quando o jogador tem estado proprio, controles, animacoes ou
parametros que nao devem ser duplicados em cada fase.

## 31. Containers nomeados reduzem dependencias frageis

Quando uma fase pode ter varios objetos do mesmo tipo, procurar um no fixo como
`Fruit` deixa de escalar bem.

Um container como `Fruits` deixa a intencao clara:

```text
Level
  Fruits
    Fruit
    Fruit2
    Fruit3
```

O codigo passa a perguntar "quais frutas existem nesta fase?", em vez de
depender de nomes individuais. Isso facilita criar desafios manuais com uma,
duas ou varias frutas.

## 32. `queue_free()` acontece no fim do frame

Quando um objeto chama `queue_free()`, ele entra na fila para ser removido, mas
pode continuar aparecendo na arvore ate o fim do frame atual.

Se outro sistema precisa checar quantos objetos ainda existem logo depois de
uma coleta, pode ser necessario esperar um frame:

```text
await get_tree().process_frame
```

Isso evita contar objetos que ja foram marcados para remocao, mas ainda nao
sumiram completamente da arvore de nos.

## 33. Pontuacao muda o comportamento do jogador

Pontuacao nao e apenas recompensa; ela ensina o jogador o que o jogo considera
uma boa jogada.

Se cada fruta vale sempre `+1`, o jogador tende a buscar a opcao mais segura:
coletar uma fruta por vez.

Se a pontuacao e calculada no fim do lancamento, como:

```text
pontos = frutas_coletadas_no_lancamento ** 2
```

o jogo passa a incentivar planejamento, ricochete e controle de forca.

Esse tipo de regra pode fortalecer o core loop quando o jogador entende a
relacao entre risco e recompensa. Mas tambem pode atrapalhar se:

- a regra nao for visivel;
- as fases nao permitirem escolhas interessantes;
- o bonus for tao forte que so exista uma estrategia correta;
- o jogador sentir que perdeu pontos por uma regra escondida.

Principio: antes de polir uma regra de pontuacao, testar se ela cria decisoes
melhores. Primeiro validamos a vontade de tentar de novo; depois criamos UI,
efeitos e explicacoes.

## 34. Limitacao transforma acao em decisao

Uma mecanica pode ser gostosa de usar e ainda assim nao sustentar um jogo.

Quando o jogador pode tentar infinitamente, errar sem custo e pontuar sem
consequencia, a experiencia vira brincadeira livre. Isso pode ser divertido por
alguns minutos, mas geralmente nao cria vontade forte de continuar.

Limitacoes simples criam pressao e significado:

- poucos lancamentos;
- pouco tempo;
- poucos recursos;
- risco de perder progresso;
- objetivo claro antes da falha.

No caso do slime, limitar lancamentos por fase muda a pergunta do jogador:

```text
"Consigo pegar a fruta?"
```

para:

```text
"Consigo pegar todas as frutas com esses lancamentos?"
```

Essa segunda pergunta e mais forte porque cria planejamento, risco e tentativa
de melhorar. O importante e a limitacao parecer justa: o jogador precisa sentir
que perdeu por decisao, mira ou forca, nao por uma regra escondida ou fase mal
posicionada.

## 35. Cenas de fase precisam de contrato claro

Carregar fases como cenas e uma boa pratica em Godot, mas a cena nao deve
parecer apenas um amontoado de nos que a cena principal acessa por caminhos
soltos.

Um `Level` fica mais profissional quando expoe uma pequena API:

- posicao inicial do jogador;
- lista de frutas;
- lista de perigos;
- quantidade inicial de frutas;
- quantidade de frutas restantes;
- dados configuraveis como `max_launches`.

Assim, `Main` controla o fluxo da partida, mas nao precisa conhecer todos os
nomes internos da fase. A fase conhece sua composicao; a cena principal conhece
a regra de vitoria, falha e troca de fase.

## 36. Total inicial e estado restante sao informacoes diferentes

Em uma fase com frutas coletaveis, existem pelo menos dois valores diferentes:

- total inicial de frutas da fase;
- frutas restantes durante a partida.

O total inicial deve ser capturado quando a fase fica pronta, antes das frutas
serem removidas. O restante pode ser calculado observando os filhos atuais ou
ignorando objetos marcados com `queue_free()`.

Misturar esses dois conceitos gera HUD confusa, como mostrar `1/1` depois que
duas frutas ja foram coletadas em uma fase que comecou com tres.

## 37. Eventos de runtime devem carregar contexto quando cenas trocam

Quando a cena principal carrega e remove fases, sinais podem chegar de objetos
que pertenciam a uma fase anterior ou de uma fase recem-criada.

Uma forma simples de evitar evento fantasma e conectar o sinal carregando a
referencia da fase:

```gdscript
fruit.collected.connect(_on_fruit_collected.bind(current_level))
spike.player_hit.connect(_on_player_hit.bind(current_level))
```

O handler entao valida:

```gdscript
if source_level != current_level:
	return
```

Esse padrao e util sempre que objetos temporarios emitem sinais para um dono
persistente: fases, salas, waves, inimigos, projeteis e pickups.

## 38. Desativar processamento nao e o mesmo que desativar presenca fisica

`process_mode = PROCESS_MODE_DISABLED` impede callbacks de processamento e
input do no, mas nao deve ser tratado como garantia de que o objeto deixou de
ser detectado por `Area2D`.

Para controlar se um personagem pode disparar `body_entered` em perigos, o
caminho mais explicito e controlar a colisao/hitbox:

- input desabilitado bloqueia comando do jogador;
- velocidade zerada bloqueia movimento residual;
- collision shape desabilitada remove presenca fisica temporaria.

Isso separa melhor tres conceitos diferentes: controle, movimento e deteccao
fisica.

## 39. Transicao de fase merece uma funcao propria

Quando uma fase reinicia, varias coisas precisam acontecer juntas:

- bloquear controle;
- zerar velocidade;
- remover fase antiga;
- criar fase nova;
- posicionar jogador no `SlimeStart`;
- reiniciar contadores;
- esconder mensagens da HUD;
- conectar sinais da fase nova;
- liberar controle.

Se essas etapas ficam espalhadas, bugs de estado aparecem com facilidade. Uma
funcao como `reset_for_level(start_position)` no jogador e funcoes menores na
`Main` deixam a transicao mais legivel e reduzem repeticao.

Regra pratica: quando o mesmo par de linhas aparece em varios lugares, como
`set_control_enabled(false)` e `velocity = Vector2.ZERO`, provavelmente existe
um conceito faltando no codigo.

## 40. Evento fisico nao e automaticamente evento de gameplay

`Area2D.body_entered` informa que um corpo entrou na area do ponto de vista da
fisica. Isso e diferente de dizer que uma regra do jogo deve acontecer.

Em transicoes como restart, troca de fase, reposicionamento do jogador ou
reativacao de collision shapes, a engine pode emitir sinais de entrada porque o
estado de sobreposicao mudou no servidor de fisica. Esse evento pode ser
tecnicamente correto, mas errado para a regra do jogo.

Por isso, perigos e coletaveis devem traduzir o evento fisico para uma regra de
gameplay com guardas explicitas:

- a fase atual ainda e a dona do evento?
- a partida esta em `PLAYING`?
- o jogador esta em um estado em que pode sofrer perigo ou coletar?

Exemplo de regra melhor que reagir diretamente ao sinal:

```gdscript
if not slime.can_hit_hazard():
	return
```

Esse padrao evita que `body_entered` durante reload, reativacao ou
reposicionamento vire game over fantasma. A licao geral e: sinais da engine
descrevem fatos tecnicos; scripts de regra decidem se esses fatos contam para o
jogo.

## 41. Visual de parede e colisao de parede podem ser coisas diferentes

Em jogos 2D, a parede que o jogador ve nao precisa ser o mesmo no que faz a
colisao. Muitas vezes o melhor resultado vem de separar:

- um sprite maior que comunica a arena, borda, material e identidade visual;
- `StaticBody2D` com `CollisionShape2D` simples para definir os limites reais.

Essa separacao evita tentar resolver problema visual com collider complexo, ou
problema de fisica com sprite esticado. O importante e que a colisao pareca
justa em relacao ao desenho.

## 42. Fases precisam de uma convencao de coordenadas

Quando cada fase posiciona arena, frutas, perigos e jogador com uma logica
diferente, pequenos ajustes visuais viram retrabalho. Uma convencao simples ja
ajuda muito:

- manter a arena sempre no mesmo centro visual;
- deixar grupos como `Fruits` e `Spikes` sem deslocamento quando nao houver
  necessidade;
- posicionar objetos dentro de uma zona segura da arena;
- evitar escala/rotacao extrema em sprites que representam objetos especificos.

Isso deixa a fase mais facil de revisar no editor e prepara o projeto para uma
refatoracao futura com dados de fase ou cenas padronizadas.

## 43. Background de jogo nao deve depender da cor padrao do viewport

Quando a area fora do tabuleiro mostra a cor cinza padrao da engine, o jogo
parece inacabado mesmo que a mecanica esteja funcionando. Em jogos 2D, uma
solucao simples e profissional e separar camadas visuais:

- um background de tela inteira para identidade e atmosfera;
- um floor/tabuleiro para a area jogavel;
- paredes, objetos e personagens por cima;
- uma cor `default_clear_color` coerente como fallback.

O background deve apoiar a leitura do jogo, nao competir com ela. Por isso, o
centro costuma ser mais calmo, e os detalhes ficam melhor nas bordas.
