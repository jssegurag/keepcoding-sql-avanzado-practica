SELECT
  c.ivr_id AS calls_ivr_id,
  c.phone_number AS calls_phone_number,
  c.ivr_result,
  c.vdn_label,
  c.start_date AS calls_start_date,
  TO_CHAR(CAST(c.start_date AS timestamp), 'YYYYMMDD') AS calls_start_date_id,
  c.end_date AS calls_end_date,
  TO_CHAR(CAST(c.end_date AS timestamp), 'YYYYMMDD') AS calls_end_date_id,
  c.total_duration,
  c.customer_segment,
  c.ivr_language,
  c.steps_module,
  c.module_aggregation,
  CASE
    WHEN EXISTS (
      SELECT 1
      FROM public.ivr_calls c2
      WHERE c2.phone_number = c.phone_number
        AND c2.ivr_id <> c.ivr_id
        AND CAST(c2.start_date AS timestamp) BETWEEN (CAST(c.start_date AS timestamp) - interval '24 hour')
                                                  AND CAST(c.start_date AS timestamp)
    ) THEN 1
    ELSE 0
  END AS repeated_phone_24H,
  CASE
    WHEN EXISTS (
      SELECT 1
      FROM public.ivr_calls c3
      WHERE c3.phone_number = c.phone_number
        AND c3.ivr_id <> c.ivr_id
        AND CAST(c3.start_date AS timestamp) BETWEEN CAST(c.start_date AS timestamp)
                                                  AND (CAST(c.start_date AS timestamp) + interval '24 hour')
    ) THEN 1
    ELSE 0
  END AS cause_recall_phone_24H
FROM public.ivr_calls c;
