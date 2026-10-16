function r = Lagrange(b,c,D,Pmin,Pmax,extraLimit)
% LAGRANGE
% Resolve o despacho económico utilizando o método dos
% multiplicadores de Lagrange.
%
% Entradas:
%   b           Vetor dos coeficientes lineares.
%   c           Vetor dos coeficientes quadráticos.
%   D           Carga total.
%   Pmin        Limites mínimos dos geradores.
%   Pmax        Limites máximos dos geradores.
%   extraLimit  Restrição adicional [gerador limite].
%
% Saída:
%   r           Estrutura com resultados do problema.

%% Garantir vetores linha

b = b(:)';
c = c(:)';

Pmin = Pmin(:)';
Pmax = Pmax(:)';

%% Sistema de equações de Lagrange

A = [2*c(1) -2*c(2)
     1       1];

B = [b(2)-b(1)
     D];

P = (A\B)';

%% Solução sem restrições adicionais

r.P_unconstrained = P;

%% Aplicação da restrição adicional (T2)

r.usedFixing = false;
r.fixedGenerator = [];
r.fixedValue = [];

if ~isempty(extraLimit)

    gerador = extraLimit(1);
    limite = extraLimit(2);

    if P(gerador) > limite

        r.usedFixing = true;

        outro = 3 - gerador;

        P(gerador) = limite;
        P(outro) = D - limite;

        r.fixedGenerator = gerador;
        r.fixedValue = limite;

    end

end

%% Verificação dos limites

if any(P < Pmin)

    error('Violação do limite mínimo.');

end

if any(P > Pmax)

    error('Violação do limite máximo.');

end

%% Cálculo dos custos

C1 = b(1)*P(1) + c(1)*P(1)^2;

C2 = b(2)*P(2) + c(2)*P(2)^2;

C = C1 + C2;

%% Custos incrementais (lambda)

lambda = b + 2*c.*P;

if r.usedFixing

    outro = 3-r.fixedGenerator;

    lambdaSystem = lambda(outro);

else

    lambdaSystem = lambda(1);

end

%% Resultados

r.P = P;

r.C1 = C1;
r.C2 = C2;
r.C = C;

r.lambda = lambda;

r.lambdaSystem = lambdaSystem;

r.lambdaDif = abs(lambda(1)-lambda(2));

end