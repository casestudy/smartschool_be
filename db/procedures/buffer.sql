\c shopman_pos;
-- Teacher subjects

--Fees trigger
DROP FUNCTION IF EXISTS bu_fee CASCADE;
CREATE OR REPLACE FUNCTION bu_fee() RETURNS TRIGGER LANGUAGE plpgsql
AS $$
DECLARE
    v_days INTEGER;
BEGIN
    v_days := (SELECT DATE_PART('day', OLD.paidon::TIMESTAMP - CURRENT_TIMESTAMP));
	IF v_days < 0 THEN
        RAISE EXCEPTION 'Cannot update or delete fee after 24 hours.' USING HINT = 'Cannot update fee after 24 hours.';
    END IF;
    RETURN NEW ;
END; $$;

DROP TRIGGER IF EXISTS bu_fees ON fees ;
CREATE OR REPLACE TRIGGER bu_fees BEFORE UPDATE ON fees 
FOR EACH ROW
EXECUTE PROCEDURE bu_fee();

DROP TRIGGER IF EXISTS bd_fees ON fees ;
CREATE OR REPLACE TRIGGER bd_fees BEFORE DELETE ON fees 
FOR EACH ROW
EXECUTE PROCEDURE bu_fee();