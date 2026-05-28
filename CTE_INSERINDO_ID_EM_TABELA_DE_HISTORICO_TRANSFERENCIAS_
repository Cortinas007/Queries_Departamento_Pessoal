Problema: Platafoma Web utilizada pela empresa precisa consultar qual a filial anterior e a filial atual das duas ultimas transferencias
  do colaborador para conseguir realizar
  a transferencia dentro do site e o manter mais automático e atualizado, sem necessidade de exclusões e inserções manuais.





WITH transferencias_ranqueadas AS (
  SELECT
    id_empresa,.
    id_colaborador,
    id_filial,
    data_transferencia,
    ROW_NUMBER() OVER (                         --- TABELA VIRTUAL USADA PARA ORGANIZAR O HISTÓRICO DE TRANSFERENCIA DO COLABORADOR
      PARTITION BY id_colaborador, id_empresa   --- FUNÇÃO DE JANELA QUE DISTRIBUI UM ID PARA CADA TRANSFERENCIA, DE FORMA DECRESCENTE, FAZENDO COM QUE AS DUAS ULTIMAS SEMPRE SEJAM 1 E 2
      ORDER BY data_transferencia DESC
    ) AS rn
  FROM historico_transferencias_filial
  WHERE id_empresa IN (:ID_EMPRESA)
),

transferencia_anterior AS (
  SELECT 
    id_empresa,             --- TABELA VIRTUAL CRIADA PARA ISOLAR A TRANSFERENCIA PASSADA E DEIXAR MAIS FACIL A SUA MANUTENÇÃO CASO NECESSÁRIO
    id_colaborador, 
    id_filial AS filial_anterior
  FROM transferencias_ranqueadas
  WHERE rn = 2
),

transferencia_atual AS (
  SELECT 
    id_empresa,             --- TABELA VIRTUAL CRIADA PARA ISOLAR A TRANSFERENCIA ATUAL E DEIXAR MAIS FACIL A SUA MANUTENÇÃO CASO NECESSÁRIO
    id_colaborador, 
    id_filial AS filial_atual, 
    data_transferencia AS data_ultima_transferencia
  FROM transferencias_ranqueadas
  WHERE rn = 1
)

SELECT
  atual.id_empresa AS "Codigo_Empresa",
  atual.id_colaborador AS "Codigo_Funcionario",
  atual.data_ultima_transferencia AS "Data_Ultima_Transferencia", --- TABELA QUE SERÁ DEMONSTRADA NA CONSULTA E NA API DA PLATAFORMA WEB
  anterior.filial_anterior AS "Filial_Anterior",
  atual.filial_atual AS "Filial_Atual"
FROM transferencia_atual atual
LEFT JOIN transferencia_anterior anterior         --- LEFTJOIN USADO PARA GARANTIR QUE O FUNCIONARIO QUE NUNCA FOI TRANSFERIDO AINDA APAREÇA NO RELATORIO
  ON atual.id_colaborador = anterior.id_colaborador  --- DEIXANDO A COLUNA FILIAL ANTERIOR EM BRANCO
  AND atual.id_empresa = anterior.id_empresa
ORDER BY 
  atual.id_colaborador ASC;
