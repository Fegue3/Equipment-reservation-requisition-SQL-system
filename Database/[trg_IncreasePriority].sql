CREATE OR ALTER TRIGGER [dbo].[trg_IncreasePriority]
ON [dbo].[Reserva]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Aumentar prioridade de utilizadores com pelo menos 2 sucessos
    UPDATE u
    SET u.Prioridade = 
        CASE 
            WHEN u.Prioridade = 'Minima' THEN 'Abaixo da Media'
            WHEN u.Prioridade = 'Abaixo da Media' THEN 'Media'
            WHEN u.Prioridade = 'Media' THEN 'Acima da Media'
            WHEN u.Prioridade = 'Acima da Media' THEN 'Maxima'
            ELSE u.Prioridade
        END
    FROM Utilizador u
    WHERE u.ID_Utilizador IN (
        SELECT r.ID_Utilizador
        FROM Reserva r
        WHERE r.Estado = 'satisfied' -- Concluída com sucesso
        GROUP BY r.ID_Utilizador
        HAVING COUNT(r.ID_Reserva) >= 2 -- Sucessos >= 2
    )

END;
