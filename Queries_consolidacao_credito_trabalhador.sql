Problema: Equipe tinha muita dificuldade de validar cada contrato do novo emprestimo do trabalhador via CLT.
Sendo assim criei uma consulta que consolida os valores de todos os contratos, tendo em vista que o sistema ERP Questor desconta o credito do trabalhador
em somente um evento, consolidando-os. 


  --- TODOS OS NOMES DE TABELAS E COLUNAS SÃO FICTICIOS ---

--- TABELA VIRTUAL QUE CONSULTA SE O FUNCIONARIO POSSUI ALGUM TIPO DE AFASTAMENTO DENTRO DO MÊS, ASSIM A EQUIPE PODE ENTENDER SE O VALOR NÃO DESCONTADO É DEVIDO ---
WITH LICENCAS_VIRTUAIS AS (
    SELECT
        licenca.id_empresa,
        licenca.id_colaborador,
        licenca.data_inicio_licenca,
        licenca.id_tipo_licenca,
        tipo.descricao_licenca AS descricao_status
    FROM historico_licencas licenca
    INNER JOIN tipo_licenca tipo ON tipo.id_tipo_licenca = licenca.id_tipo_licenca
    WHERE licenca.data_inicio_licenca <= (:DATA_REFERENCIA)
      AND licenca.data_fim_licenca >= (CAST(:DATA_REFERENCIA AS DATE) + INTERVAL '29 DAYS') --- INTERVALO SERVE PARA VER O AFASTAMENTO COM O MES 
                                                                                            --- FECHADO E SEM PRECISAR ADICIONAR DATA FIM NA EMISSÃO 
) 

SELECT
    emprestimo.id_empresa AS "Codigo_Empresa",
    emprestimo.id_colaborador AS "Codigo_Func",
    colab.nome_colaborador AS "Nome",
  --- VERIFICA SE O FUNCIONARIO FOI DESLIGADO DURANTE O MES, CASO NÃO, DETALHA SE ESTA TRABALHANDO NORMAL OU SEU TIPO DE AFASTAMENTO ---
    CASE
        WHEN colab.data_desligamento <= (CAST(:DATA_REFERENCIA AS DATE) + INTERVAL '29 DAYS') THEN 'Desligado' 
        WHEN lic_virt.data_inicio_licenca IS NOT NULL THEN lic_virt.descricao_status
        ELSE 'Trabalhando'
    END AS "StatusFuncionarioCompetencia",
   --- INFORMA A DATA DE DESLIGAMENTO E AFASTAMENTO DO FUNCIONARIO (SE HOUVER) --- 
    CASE
        WHEN colab.data_desligamento <= (CAST(:DATA_REFERENCIA AS DATE) + INTERVAL '29 DAYS') THEN colab.data_desligamento
        WHEN lic_virt.data_inicio_licenca IS NOT NULL THEN lic_virt.data_inicio_licenca
    END AS "Data_de_Demissao_ou_Afastamento",
    
    categ_emprestimo.descricao_categoria AS "Tipo_Emprestimo",
    parcela.mes_referencia AS "Competencia_de_Desconto",
    SUM(parcela.valor_parcela) AS "Valor_Total_Parcela",
    folha.valor_descontado_folha AS "Valor_Pago_Folha",
    (SUM(parcela.valor_parcela) - folha.valor_descontado_folha) AS "Diferenca" 

FROM emprestimo_funcionario emprestimo

INNER JOIN categoria_emprestimo categ_emprestimo 
    ON categ_emprestimo.id_categoria = emprestimo.id_categoria
    
LEFT JOIN parcela_emprestimo parcela 
    ON parcela.id_empresa = emprestimo.id_empresa 
   AND parcela.id_colaborador = emprestimo.id_colaborador 
   AND parcela.numero_parcela = emprestimo.numero_parcela 
   AND parcela.data_emprestimo = emprestimo.data_emprestimo
   
LEFT JOIN LICENCAS_VIRTUAIS lic_virt 
    ON lic_virt.id_empresa = emprestimo.id_empresa 
   AND lic_virt.id_colaborador = emprestimo.id_colaborador    --- TODOS ESSES JOINS SÃO DE DIFERENTES TABELAS DE CADASTROS DE EMPRESTIMO 
   
INNER JOIN colaborador colab 
    ON colab.id_empresa = emprestimo.id_empresa 
   AND colab.id_colaborador = emprestimo.id_colaborador
   
INNER JOIN evento_folha_pagamento folha 
    ON folha.id_empresa = emprestimo.id_empresa 
   AND folha.id_colaborador = emprestimo.id_colaborador 

WHERE emprestimo.id_empresa IN (:ID_EMPRESA)
  AND parcela.mes_referencia IN (:DATA_REFERENCIA)
  AND folha.id_evento_folha = 4004
  AND folha.id_periodo_folha IN (:ID_PERIODO_FOLHA)

GROUP BY
    emprestimo.id_empresa,
    emprestimo.id_colaborador,
    colab.nome_colaborador,
    categ_emprestimo.descricao_categoria,  --- AGRUPANDO PARA CONSOLIDAR OS VALORES
    parcela.mes_referencia,
    colab.data_desligamento,
    lic_virt.data_inicio_licenca,
    lic_virt.descricao_status,
    folha.valor_descontado_folha

ORDER BY 
    emprestimo.id_colaborador ASC;
