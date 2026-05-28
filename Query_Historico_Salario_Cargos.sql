

SELECT
    colab.id_filial AS "Filial",
    colab.id_colaborador AS "Codigo_Funcionario",
    colab.nome_colaborador AS "Nome_Funcionario",
    colab.data_desligamento AS "Data_Demissao",
    hist_cargo.data_inicio_cargo AS "Data_Inicio_Cargo",
    hist_cargo.id_cargo AS "Codigo_Cargo",
    c.descricao_cargo AS "Nome_Cargo",
    hist_sal.data_alteracao AS "Data_Alteracao_Salario",
    
    -- CÁLCULO DE PERCENTUAL DE AUMENTO USANDO FUNÇÃO DE JANELA (LAG)
    ROUND(
        (
            (hist_sal.valor_salario / NULLIF(
                LAG(hist_sal.valor_salario) OVER(
                    PARTITION BY hist_sal.id_empresa, hist_sal.id_colaborador 
                    ORDER BY hist_sal.data_alteracao ASC
                ), 0)
            ) - 1
        ) * 100
    , 2) AS "Percentual_de_Aumento",
    
    hist_sal.valor_salario AS "Salario",
    
    -- SUBCONSULTA ESCALAR PARA BUSCAR O MOTIVO DO DISSÍDIO/PROMOÇÃO
    (SELECT m.descricao_motivo FROM motivo_alteracao m WHERE m.id_motivo = hist_sal.id_motivo_alteracao) AS "Motivo_Alteracao"

FROM colaborador AS colab

LEFT JOIN historico_cargo AS hist_cargo 
    ON hist_cargo.id_colaborador = colab.id_colaborador 
   AND hist_cargo.id_cargo = colab.id_cargo 
   AND hist_cargo.id_empresa = colab.id_empresa

INNER JOIN cargo AS c 
    ON c.id_cargo = colab.id_cargo

LEFT JOIN historico_salarial AS hist_sal 
    ON hist_sal.id_empresa = colab.id_empresa 
   AND hist_sal.id_colaborador = colab.id_colaborador

WHERE (0 IN (:ID_EMPRESA) OR colab.id_empresa IN (:ID_EMPRESA)) --- USANDO ESSE FILTRO PARA CONSEGUIR SELECIONAR APENAS UMA EMPRESA OU TODAS DO BANCO
  AND (0 IN (:ID_FILIAL)  OR colab.id_filial IN (:ID_FILIAL))   --- ASSIM COMO OS ESTABELECIMENTOS
  AND colab.id_tipo_contrato NOT IN (2)

ORDER BY 
    colab.id_colaborador ASC,
    hist_sal.data_alteracao ASC;
