CREATE OR ALTER TRIGGER [dbo].[trg_UpdateEquipmentState]
ON [dbo].[Reserva]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Atualizar o estado dos equipamentos com base no estado da reserva
    UPDATE e
    SET e.Estado_Equipamento = CASE
                                  WHEN r.Estado IN ('active', 'waiting') THEN 'reservado'
                                  WHEN r.Estado = 'satisfied' THEN 'em uso'
                                  WHEN r.Estado IN ('forgotten', 'canceled') THEN 'disponível'
                                  ELSE e.Estado_Equipamento -- Manter estado atual para outros casos
                               END
    FROM dbo.Equipamento e
    INNER JOIN dbo.ReservaEquipamento re ON e.ID_Equipamento = re.ID_Equipamento
    INNER JOIN dbo.Reserva r ON re.ID_Reserva = r.ID_Reserva
    WHERE EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.ID_Reserva = r.ID_Reserva
    );
END;
