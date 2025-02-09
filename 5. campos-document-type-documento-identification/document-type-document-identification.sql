WITH identified_client AS (
  SELECT DISTINCT ON (s.ivr_id)
         s.ivr_id,
         s.document_type,
         s.document_identification,
         s.step_sequence
  FROM public.ivr_steps s
  WHERE s.document_type IS NOT NULL
    AND s.document_identification IS NOT NULL
    AND s.document_type <> 'UNKNOWN'
    AND s.document_identification <> 'UNKNOWN'
  ORDER BY s.ivr_id, s.step_sequence  
)
SELECT
  c.ivr_id AS calls_ivr_id,
  c.phone_number AS calls_phone_number,
  c.ivr_result AS calls_ivr_result,
  c.vdn_label AS calls_vdn_label,
  CASE
    WHEN c.vdn_label LIKE 'ATC%' THEN 'FRONT'
    WHEN c.vdn_label LIKE 'TECH%' THEN 'TECH'
    WHEN c.vdn_label = 'ABSORPTION' THEN 'ABSORPTION'
    ELSE 'RESTO'
  END AS vdn_aggregation,
  c.start_date AS calls_start_date,
  TO_CHAR(CAST(c.start_date AS timestamp), 'YYYYMMDD') AS calls_start_date_id,
  c.end_date AS calls_end_date,
  TO_CHAR(CAST(c.end_date AS timestamp), 'YYYYMMDD') AS calls_end_date_id,
  c.total_duration AS calls_total_duration,
  c.customer_segment AS calls_customer_segment,
  c.ivr_language AS calls_ivr_language,
  c.steps_module AS calls_steps_module,
  c.module_aggregation AS calls_module_aggregation,
  ic.document_type AS customer_document_type,
  ic.document_identification AS customer_document_identification
FROM public.ivr_calls c
  LEFT JOIN identified_client ic
    ON c.ivr_id::float = ic.ivr_id;
