function r = T1(b,c,D,popSize,maxGen,seed)
% T1
% Despacho economico.

%% Limites

Pmin = [0.10 0.10];
Pmax = [1.00 1.00];

%% Validacao

if D < sum(Pmin)
    error('T1: carga inferior a potencia minima total.');
end

if D > sum(Pmax)
    error('T1: carga superior a potencia maxima total.');
end

%% Lagrange

L = Lagrange( ...
    b,c,D,Pmin,Pmax,[]);

%% GA

G = GA( ...
    b,c,D,popSize,maxGen,seed,Pmin,Pmax,[]);

%% Resultados Lagrange

r.P_L = L.P;
r.C_L = L.C;
r.lambda_L = L.lambda;
r.lambdaSystem_L = L.lambdaSystem;

%% Resultados GA

r.P_GA = G.P;
r.C_GA = G.C;
r.lambda_GA = G.lambda;
r.lambdaSystem_GA = G.lambdaSystem;

%% Estatistica

r.P_resultados = G.P10;
r.R = G.R;

r.melhor = G.melhor;
r.media = G.media;
r.pior = G.pior;

r.tabela10 = G.tabela10;

%% Comparacao

r.tabelaComparacao = table( ...
    [L.P(1);G.P(1)], ...
    [L.P(2);G.P(2)], ...
    [L.C;G.C], ...
    [L.lambdaSystem;G.lambdaSystem], ...
    'RowNames', ...
    {'Lagrange','GA'}, ...
    'VariableNames', ...
    {'P1','P2','Custo','LambdaSistema'});

end