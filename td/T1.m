function resultados = T1(b, c, D, popSize, maxGen, seed)

%% =========================================================
% T1 - DESPACHO ECONOMICO
% Funcao reutilizavel
%
% Entradas:
%   b       -> coeficientes lineares [b1 b2]
%   c       -> coeficientes quadraticos [c1 c2]
%   D       -> carga total
%   popSize -> tamanho da populacao do GA
%   maxGen  -> numero maximo de geracoes
%   seed    -> semente do RNG
%
% Saida:
%   resultados -> estrutura com todos os resultados do T1
%% =========================================================


%% Garantir que b e c sao vetores linha

b = b(:)';
c = c(:)';


%% Limites dos geradores

Pmin = [0.10 0.10];
Pmax = [1.00 1.00];


%% Restricao de balanco de potencia

Aeq = [1 1];
beq = D;


%% Funcao de custo

fcusto = @(P) sum(b.*P + c.*P.^2, 2);


%% =========================================================
% T1.a - Metodo dos multiplicadores de Lagrange
% ==========================================================

A = [2*c(1)  -2*c(2);
     1         1];

B = [b(2) - b(1);
     D];

X = A\B;

P_L = X';

C_L = fcusto(P_L);

lambda_L = b + 2*c.*P_L;


%% =========================================================
% T1.b - Resolucao com algoritmo genetico (GA)
% ==========================================================

opts = optimoptions('ga', ...
    'PopulationSize', popSize, ...
    'MaxGenerations', maxGen);


rng(seed)

[P_GA, C_GA] = ga(fcusto, 2, [], [], ...
                  Aeq, beq, ...
                  Pmin, Pmax, [], opts);


lambda_GA = b + 2*c.*P_GA;


%% =========================================================
% T1.c - Comparacao entre Lagrange e GA
% ==========================================================

% Os resultados da comparacao serao guardados
% na estrutura "resultados"


%% =========================================================
% T1.d - Estudo estatistico: 10 execucoes
% ==========================================================

nexec = 10;

R = zeros(nexec,1);
P_resultados = zeros(nexec,2);


for r = 1:nexec

    rng(r)

    [P_aux, C_aux] = ga(fcusto, 2, [], [], ...
                        Aeq, beq, ...
                        Pmin, Pmax, [], opts);

    P_resultados(r,:) = P_aux;
    R(r) = C_aux;

end


%% Estatisticas

melhor = min(R);
media = mean(R);
pior = max(R);


%% =========================================================
% Guardar todos os resultados
% ==========================================================

% T1.a - Lagrange

resultados.P_L = P_L;
resultados.C_L = C_L;
resultados.lambda_L = lambda_L;


% T1.b - GA

resultados.P_GA = P_GA;
resultados.C_GA = C_GA;
resultados.lambda_GA = lambda_GA;


% T1.c - Comparacao

resultados.comparacao.P_L = P_L;
resultados.comparacao.P_GA = P_GA;

resultados.comparacao.C_L = C_L;
resultados.comparacao.C_GA = C_GA;

resultados.comparacao.lambda_L = lambda_L;
resultados.comparacao.lambda_GA = lambda_GA;


% T1.d - 10 execucoes

resultados.P_execucoes = P_resultados;
resultados.C_execucoes = R;

resultados.melhor = melhor;
resultados.media = media;
resultados.pior = pior;


% Guardar tambem os parametros usados

resultados.b = b;
resultados.c = c;
resultados.D = D;

resultados.popSize = popSize;
resultados.maxGen = maxGen;
resultados.seed = seed;

end