CREATE OR ALTER TRIGGER [dbo].[trg_ValidarPrioridadeDinamica]
ON [dbo].[Utilizador]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Atualiza a prioridade corrente para garantir que nunca ultrapassa o limite baseado no tipo de utilizador
    UPDATE Utilizador
    SET Prioridade = 
        CASE 
            -- Presidente do Departamento (PD): sempre "máxima"
            WHEN ID_TipoUtilizador = 'PD' THEN 'Maxima'

            -- Professores (PR): não pode exceder "acima da média", mas pode descer
            WHEN ID_TipoUtilizador = 'PR' THEN 
                CASE 
                    WHEN Prioridade NOT IN ('Media', 'Abaixo da Media', 'Minima') THEN 'Acima da Media'
                    ELSE Prioridade -- Mantém valor reduzido
                END

            -- Outros utilizadores: não pode exceder "média", mas pode descer
            WHEN ID_TipoUtilizador IN ('BS', 'MS', 'DS', 'SF', 'XT') THEN 
                CASE 
                    WHEN Prioridade NOT IN ('Media', 'Abaixo da Media', 'Minima') THEN 'Media'
                    ELSE Prioridade -- Mantém valor reduzido
                END

            -- Mantém o valor atual para outros casos
            ELSE Prioridade
        END
    WHERE ID_Utilizador IN (
        SELECT ID_Utilizador FROM inserted -- Apenas para os registros afetados
    );
END;
