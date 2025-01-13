CREATE OR ALTER   TRIGGER [dbo].[trg_ReducePriority]
ON [dbo].[Penalizacao]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Atualizar prioridade do utilizador com base nas penalizações
    UPDATE u
    SET u.Prioridade = 
        CASE 
            WHEN u.Prioridade = 'Maxima' THEN 'Acima da Media'
            WHEN u.Prioridade = 'Acima da Media' THEN 'Media'
            WHEN u.Prioridade = 'Media' THEN 'Abaixo da Media'
            WHEN u.Prioridade = 'Abaixo da Media' THEN 'Minima'
            ELSE 'Minima'
        END
    FROM Utilizador u
    WHERE u.ID_Utilizador IN (
        SELECT r.ID_Utilizador
        FROM Penalizacao p
        INNER JOIN Reserva r ON p.ID_Reserva = r.ID_Reserva
        GROUP BY r.ID_Utilizador
        HAVING SUM(p.Valor_Penalizacao) >= 5 -- Penalizações totais iguais ou superiores a 5
    );
END;
