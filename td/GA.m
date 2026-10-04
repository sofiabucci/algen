function r = GA(b,c,D,popSize,maxGen,seed,Pmin,Pmax,extraLimit,outputFcn)
% GA
% Resolve o despacho economico usando o algoritmo genetico.

%% Garantir que os vetores sao linhas

b = b(:)';
c = c(:)';

Pmin = Pmin(:)';
Pmax = Pmax(:)';

%% Valores opcionais

if nargin < 9
    extraLimit = [];
end

if nargin < 10
    outputFcn = [];
end

%% Limites

ub = Pmax;

if ~isempty(extraLimit)

    gerador = extraLimit(1);
    limite = extraLimit(2);

    ub(gerador) = min(ub(gerador),limite);

end

%% Validacao

if sum(Pmin) > D
    error('A carga e inferior a potencia minima total.');
end

if sum(ub) < D
    error('A carga nao pode ser satisfeita com estes limites.');
end

%% Funcao de custo

fcusto = @(P) sum(b.*P + c.*P.^2,2);

%% Opcoes

opts = optimoptions('ga', ...
    'PopulationSize',popSize, ...
    'MaxGenerations',maxGen, ...
    'Display','off');

if ~isempty(outputFcn)
    opts.OutputFcn = outputFcn;
end

%% Execucao

rng(seed);

[P,C] = ga( ...
    fcusto,2,[],[], ...
    [1 1],D,Pmin,ub,[],opts);

%% Custos marginais

lambda = b + 2*c.*P;

if isempty(extraLimit)

    lambdaSystem = lambda(1);

else

    gerador = extraLimit(1);
    outro = 3 - gerador;

    if abs(P(gerador)-ub(gerador)) < 1e-8
        lambdaSystem = lambda(outro);
    else
        lambdaSystem = lambda(1);
    end

end

%% Resultados

r.P = P;
r.C = C;
r.lambda = lambda;
r.lambdaSystem = lambdaSystem;

%% Estatistica

nexec = 10;

R = zeros(nexec,1);
P10 = zeros(nexec,2);

opts10 = optimoptions('ga', ...
    'PopulationSize',popSize, ...
    'MaxGenerations',maxGen, ...
    'Display','off');

for k = 1:nexec

    rng(k);

    [Pk,Ck] = ga( ...
        fcusto,2,[],[], ...
        [1 1],D,Pmin,ub,[],opts10);

    P10(k,:) = Pk;
    R(k) = Ck;

end

%% Resultados estatisticos

r.P10 = P10;
r.R = R;

r.melhor = min(R);
r.media = mean(R);
r.pior = max(R);

%% Tabela

r.tabela10 = table( ...
    (1:nexec)', ...
    P10(:,1), ...
    P10(:,2), ...
    R, ...
    'VariableNames', ...
    {'Execucao','P1','P2','Custo'});

end