Problema: A empresa utiliza uma plataforma web integrada diretamente ao banco de dados do ERP corporativo para fornecer relatórios de Business Partner 
   em tempo real para os clientes.
    Sempre que uma nova empresa é integrada/cadastrada no banco de dados, o histórico de alterações salariais dos colaboradores é importado em formato bruto. 
    O sistema nativo não calcula retroativamente o percentual de aumento de cada dissídio ou promoção ao longo dos anos, defasando a ficha financeira dos colaboradores.
Isso quebrava a automação API que alimenta o site.
Para eliminar este retrabalho, desenvolvi uma consulta em PostgreSQL que utiliza Funções de Janela (LAG e OVER). 
    A inteligência da query analisa o histórico salarial cronológico de cada colaborador de forma automatizada, 
    detecta o salário anterior na linha de cima e calcula o percentual exato de aumento em tempo real diretamente na fonte de dados.

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
            (hist_sal.valor_salario / NULLIF(          --- USO DO NULLIF PARA CASO HAJA ALGUM COLABORADOR QUE NÃO POSSUA HISTÓRICO DE SALARIO A CONSULTA NÃO QUEBRAR DIVIDINDO POR 0 ---
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
