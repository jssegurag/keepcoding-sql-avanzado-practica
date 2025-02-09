WITH ivr_data AS (
    SELECT 
        c.ivr_id AS calls_ivr_id,
        c.phone_number AS calls_phone_number,
        c.ivr_result,
        c.vdn_label,
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
        c.total_duration,
        c.customer_segment,
        c.ivr_language,
        c.steps_module,
        c.module_aggregation,
        MAX(CASE WHEN m.module_name = 'AVERIA_MASIVA' THEN 1 ELSE 0 END) AS masiva_lg,
        MAX(CASE WHEN s.step_name = 'CUSTOMERINFOBYPHONE.TX' AND s.step_result = 'OK' THEN 1 ELSE 0 END) AS info_by_phone_lg,
        MAX(CASE WHEN s.step_name = 'CUSTOMERINFOBYDNI.TX' AND s.step_result = 'OK' THEN 1 ELSE 0 END) AS info_by_dni_lg,
        MIN(NULLIF(s.document_type, 'UNKNOWN')) AS document_type,
        MIN(NULLIF(s.document_identification, 'UNKNOWN')) AS document_identification,
        MIN(NULLIF(s.customer_phone, 'UNKNOWN')) AS customer_phone,
        MAX(s.billing_account_id) AS billing_account_id
    FROM public.ivr_calls c
    LEFT JOIN public."ivr_modules.csv" m ON c.ivr_id::float = m.ivr_id
    LEFT JOIN public.ivr_steps s ON c.ivr_id::float = s.ivr_id AND m.module_sequece = s.module_sequece
    GROUP BY c.ivr_id, c.phone_number, c.ivr_result, c.vdn_label, c.start_date, c.end_date, 
             c.total_duration, c.customer_segment, c.ivr_language, c.steps_module, c.module_aggregation
),
ivr_repeated_calls AS (
    SELECT 
        c1.ivr_id,
        MAX(CASE WHEN c2.ivr_id IS NOT NULL THEN 1 ELSE 0 END) AS repeated_phone_24H,
        MAX(CASE WHEN c3.ivr_id IS NOT NULL THEN 1 ELSE 0 END) AS cause_recall_phone_24H
    FROM public.ivr_calls c1
    LEFT JOIN public.ivr_calls c2 
        ON c1.phone_number = c2.phone_number 
        AND c1.ivr_id <> c2.ivr_id
        AND CAST(c2.start_date AS timestamp) BETWEEN (CAST(c1.start_date AS timestamp) - INTERVAL '24 hours') 
                                                  AND CAST(c1.start_date AS timestamp)
    LEFT JOIN public.ivr_calls c3 
        ON c1.phone_number = c3.phone_number 
        AND c1.ivr_id <> c3.ivr_id
        AND CAST(c3.start_date AS timestamp) BETWEEN CAST(c1.start_date AS timestamp) 
                                                  AND (CAST(c1.start_date AS timestamp) + INTERVAL '24 hours')
    GROUP BY c1.ivr_id
)
SELECT 
    d.calls_ivr_id,
    d.calls_phone_number,
    d.ivr_result,
    d.vdn_aggregation,
    d.calls_start_date,
    d.calls_end_date,
    d.total_duration,
    d.customer_segment,
    d.ivr_language,
    d.steps_module,
    d.module_aggregation,
    COALESCE(d.document_type, 'UNKNOWN') AS document_type,
    COALESCE(d.document_identification, 'UNKNOWN') AS document_identification,
    COALESCE(d.customer_phone, 'UNKNOWN') AS customer_phone,
    COALESCE(d.billing_account_id, 'UNKNOWN') AS billing_account_id,
    COALESCE(d.masiva_lg, 0) AS masiva_lg,
    COALESCE(d.info_by_phone_lg, 0) AS info_by_phone_lg,
    COALESCE(d.info_by_dni_lg, 0) AS info_by_dni_lg,
    COALESCE(r.repeated_phone_24H, 0) AS repeated_phone_24H,
    COALESCE(r.cause_recall_phone_24H, 0) AS cause_recall_phone_24H
FROM ivr_data d
LEFT JOIN ivr_repeated_calls r ON d.calls_ivr_id = r.ivr_id;
