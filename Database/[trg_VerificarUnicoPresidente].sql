CREATE OR ALTER TRIGGER [dbo].[VerificarUnicoPresidente]
ON [dbo].[Utilizador]
AFTER INSERT
AS
BEGIN
    -- Verifica se h� tentativa de inserir um utilizador com ID_TipoUtilizador = 'PD'
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE ID_TipoUtilizador = 'PD'
    )
    BEGIN
        -- Verifica se j� existe um Presidente na tabela
        IF EXISTS (
            SELECT 1
            FROM Utilizador
            WHERE ID_TipoUtilizador = 'PD'
              AND ID_Utilizador NOT IN (SELECT ID_Utilizador FROM inserted)
        )
        BEGIN
            -- Apaga o registro inserido
            DELETE FROM Utilizador
            WHERE ID_Utilizador IN (SELECT ID_Utilizador FROM inserted);

            -- Lan�a um erro
            RAISERROR('Ja existe um utilizador com o tipo "Presidente". Apenas um Presidente pode existir no sistema.', 16, 1);
        END;

        -- Garante que a prioridade seja "m�xima" para o Presidente
        UPDATE Utilizador
        SET Prioridade = 'Maxima'
        WHERE ID_TipoUtilizador = 'PD'
          AND ID_Utilizador IN (SELECT ID_Utilizador FROM inserted);
    END;
END;
