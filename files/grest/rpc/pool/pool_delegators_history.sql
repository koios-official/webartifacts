CREATE OR REPLACE FUNCTION grest.pool_delegators_history(_pool_bech32 text, _epoch_no word31type DEFAULT NULL)
RETURNS TABLE (
  stake_address character varying,
  amount text,
  epoch_no word31type
)
LANGUAGE plpgsql
AS $$
#variable_conflict use_column
DECLARE
  _pool_id bigint;
BEGIN
  SELECT id INTO _pool_id FROM pool_hash WHERE pool_hash.hash_raw = DECODE(b32_decode(_pool_bech32),'hex');
  IF _epoch_no IS NULL THEN
    RETURN QUERY
      SELECT
        grest.cip5_hex_to_stake_addr(sa.hash_raw),
        es.amount::text,
        es.epoch_no
      FROM
        public.epoch_stake AS es
      INNER JOIN public.stake_address AS sa ON es.addr_id = sa.id
      WHERE
        es.pool_id = _pool_id
      ORDER BY
        es.epoch_no DESC, es.amount DESC;
  ELSE
    RETURN QUERY
      SELECT
        grest.cip5_hex_to_stake_addr(sa.hash_raw),
        es.amount::text,
        es.epoch_no
      FROM
        public.epoch_stake AS es
      INNER JOIN public.stake_address AS sa ON es.addr_id = sa.id
      WHERE
        es.pool_id = _pool_id
        AND
        es.epoch_no = _epoch_no
      ORDER BY
        es.amount DESC;
  END IF;
END;
$$;

COMMENT ON FUNCTION grest.pool_delegators IS 'Return information about active delegators (incl. history) for a given pool and epoch number - current epoch if not provided.'; --noqa: LT01
