function r = GA(b,c,D,popSize,maxGen,seed,...
                Pmin,Pmax,extraLimit,outputFcn)
% GA
% Resolve o despacho económico utilizando o algoritmo
% genético do MATLAB.
%
% Entradas:
%   b            Coeficientes lineares.
%   c            Coeficientes quadráticos.
%   D            Carga total.
%   popSize      Tamanho da população.
%   maxGen       Número máximo de gerações.
%   seed         Semente de aleatoriedade.
%   Pmin         Limites mínimos.
%   Pmax         Limites máximos.
%   extraLimit   Restrição adicional do T2.
%   outputFcn    Função para registar convergência.
%
% Saída:
%   r            Estrutura com resultados.

%% Argumentos opcionais

if nargin < 9
    extraLimit = [];
end

if nargin < 10
    outputFcn = [];
end

%% Limites do problema

ub = Pmax;

if ~isempty(extraLimit)

    gerador = extraLimit(1);
    limite = extraLimit(2);

    ub(gerador) = min(ub(gerador),limite);

end

%% Função objetivo

fcusto = @(P) sum(b.*P + c.*P.^2,2);

%% Opções do algoritmo genético

opts = optimoptions('ga', ...
    'PopulationSize',popSize,...
    'MaxGenerations',maxGen,...
    'Display','off');

if ~isempty(outputFcn)

    opts = optimoptions( ...
        opts,...
        'OutputFcn',outputFcn);

end

%% Execução principal

rng(seed);

[P,C] = ga( ...
    fcusto,...
    2,...
    [],[],...
    [1 1],D,...
    Pmin,ub,...
    [],opts);

%% Custos incrementais

lambda = b + 2*c.*P;

if isempty(extraLimit)

    lambdaSystem = lambda(1);

else

    gerador = extraLimit(1);

    if abs(P(gerador)-ub(gerador)) < 1e-8

        lambdaSystem = lambda(3-gerador);

    else

        lambdaSystem = lambda(1);

    end

end

%% Estudo estatístico (10 execuções)

nexec = 10;

R = zeros(nexec,1);

P10 = zeros(nexec,2);

opts10 = optimoptions('ga', ...
    'PopulationSize',popSize,...
    'MaxGenerations',maxGen,...
    'Display','off');

for k = 1:nexec

    rng(k);

    [Pk,Ck] = ga( ...
        fcusto,...
        2,...
        [],[],...
        [1 1],D,...
        Pmin,ub,...
        [],opts10);

    P10(k,:) = Pk;

    R(k) = Ck;

end

%% Estatísticas

r.melhor = min(R);

r.media = mean(R);

r.pior = max(R);

r.desvioPadrao = std(R);

r.variancia = var(R);

%% Resultados

r.P = P;

r.C = C;

r.lambda = lambda;

r.lambdaSystem = lambdaSystem;

r.P10 = P10;

r.R = R;

%% Tabela das execuções

r.tabela10 = table( ...
    (1:nexec)', ...
    P10(:,1), ...
    P10(:,2), ...
    R, ...
    'VariableNames', ...
    {'Execucao','P1','P2','Custo'});

end