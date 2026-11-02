function r = GAProprio(b,c,D,popSize,maxGen,seed,Pmin,Pmax)
% GAPROPRIO
% Algoritmo Genetico desenvolvido pelo grupo.
%
% Caracteristicas:
%   - Codificacao real
%   - Selecao por torneio
%   - Cruzamento aritmetico
%   - Mutacao gaussiana
%   - Elitismo
%   - Criterio de paragem por numero maximo de geracoes
%
% Entradas:
%   b           Coeficientes lineares
%   c           Coeficientes quadraticos
%   D           Carga total
%   popSize     Tamanho da populacao
%   maxGen      Numero de geracoes
%   seed        Semente aleatoria
%   Pmin        Potencias minimas
%   Pmax        Potencias maximas
%
% Saida:
%   r           Estrutura de resultados

%% Inicializacao

rng(seed);

taxaMutacao = 0.10;

hist = zeros(maxGen,1);

%% Populacao inicial

pop = zeros(popSize,2);

for i = 1:popSize

    valido = false;

    while ~valido

        P1 = Pmin(1) + ...
            rand*(Pmax(1)-Pmin(1));

        P2 = D - P1;

        valido = ...
            (P2 >= Pmin(2)) && ...
            (P2 <= Pmax(2));

    end

    pop(i,:) = [P1 P2];

end

%% Ciclo evolutivo

for g = 1:maxGen

    %% Avaliacao

    custo = zeros(popSize,1);

    for i = 1:popSize

        P1 = pop(i,1);
        P2 = pop(i,2);

        custo(i) = ...
            b(1)*P1 + c(1)*P1^2 + ...
            b(2)*P2 + c(2)*P2^2;

    end

    %% Melhor individuo

    [melhorCusto,pos] = min(custo);

    elite = pop(pos,:);

    hist(g) = melhorCusto;

    %% Nova populacao

    novaPop = zeros(size(pop));

    %% Elitismo

    novaPop(1,:) = elite;

    idx = 2;

    while idx <= popSize

        %% Selecao por torneio

        pai1 = pop(torneio(custo),:);

        pai2 = pop(torneio(custo),:);

        %% Cruzamento aritmetico

        alpha = rand;

        filho1 = ...
            alpha*pai1 + ...
            (1-alpha)*pai2;

        filho2 = ...
            alpha*pai2 + ...
            (1-alpha)*pai1;

        %% Mutacao

        if rand < taxaMutacao

            filho1(1) = ...
                filho1(1) + ...
                0.05*randn;

        end

        if rand < taxaMutacao

            filho2(1) = ...
                filho2(1) + ...
                0.05*randn;

        end

        %% Recalcular P2

        filho1(2) = D - filho1(1);

        filho2(2) = D - filho2(1);

        %% Reparacao

        filho1 = reparar( ...
            filho1,D,Pmin,Pmax);

        filho2 = reparar( ...
            filho2,D,Pmin,Pmax);

        %% Insercao

        novaPop(idx,:) = filho1;

        if idx+1 <= popSize
            novaPop(idx+1,:) = filho2;
        end

        idx = idx + 2;

    end

    pop = novaPop;

end

%% Avaliacao final

custoFinal = zeros(popSize,1);

for i = 1:popSize

    P1 = pop(i,1);

    P2 = pop(i,2);

    custoFinal(i) = ...
        b(1)*P1 + c(1)*P1^2 + ...
        b(2)*P2 + c(2)*P2^2;

end

%% Melhor solucao

[C,pos] = min(custoFinal);

P = pop(pos,:);

%% Lambdas

lambda = b + 2*c.*P;

lambdaSystem = mean(lambda);

%% Estatísticas da convergência

r.melhor = min(hist);

r.media = mean(hist);

r.pior = max(hist);

r.desvioPadrao = std(hist);

%% Resultados

r.P = P;

r.C = C;

r.lambda = lambda;

r.lambdaSystem = lambdaSystem;

r.hist = hist;

end

%% =====================================================
%% FUNCOES LOCAIS
%% =====================================================

function idx = torneio(custo)
% SELECAO POR TORNEIO

k = 3;

candidatos = randperm(length(custo),k);

[~,p] = min(custo(candidatos));

idx = candidatos(p);

end


function individuo = reparar( ...
    individuo,D,Pmin,Pmax)

% REPARACAO DE LIMITES

P1 = individuo(1);

P1 = max(Pmin(1),P1);

P1 = min(Pmax(1),P1);

P2 = D - P1;

if P2 < Pmin(2)

    P2 = Pmin(2);

    P1 = D - P2;

end

if P2 > Pmax(2)

    P2 = Pmax(2);

    P1 = D - P2;

end

individuo = [P1 P2];

end