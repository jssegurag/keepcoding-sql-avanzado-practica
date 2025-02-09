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
  m.module_sequece AS module_sequece,
  m.module_name AS module_name,
  m.module_duration AS module_duration,
  m.module_result AS module_result,
  s.step_sequence AS step_sequence,
  s.step_name AS step_name,
  s.step_result AS step_result,
  s.step_description_error AS step_description_error,
  s.document_type AS document_type,
  s.document_identification AS document_identification,
  s.customer_phone AS customer_phone,
  s.billing_account_id AS billing_account_id
FROM public.ivr_calls c
  LEFT JOIN public."ivr_modules.csv" m 
    ON c.ivr_id::float = m.ivr_id
  LEFT JOIN public.ivr_steps s 
    ON c.ivr_id::float = s.ivr_id
   AND m.module_sequece = s.module_sequece;
