CREATE TABLE "Programa" (
  "id" serial PRIMARY KEY,
  "nombre" varchar NOT NULL,
  "descripcion" text,
  "fechaInicio" date,
  "fechaFin" date
);

CREATE TABLE "Bootcamp" (
  "id" serial PRIMARY KEY,
  "programa_id" int NOT NULL,
  "nombre" varchar NOT NULL,
  "descripcion" text,
  "fechaInicio" date,
  "fechaFin" date
);

CREATE TABLE "Modulo" (
  "id" serial PRIMARY KEY,
  "nombre" varchar NOT NULL,
  "descripcion" text,
  "profesor_id" int NOT NULL
);

CREATE TABLE "BootcampModulo" (
  "id" serial PRIMARY KEY,
  "bootcamp_id" int NOT NULL,
  "modulo_id" int NOT NULL
);

CREATE TABLE "Alumno" (
  "id" serial PRIMARY KEY,
  "bootcamp_id" int NOT NULL,
  "nombre" varchar NOT NULL,
  "correo" varchar,
  "fechaNacimiento" date
);

CREATE TABLE "AlumnoModulo" (
  "id" serial PRIMARY KEY,
  "alumno_id" int NOT NULL,
  "bootcamp_modulo_id" int NOT NULL
);

CREATE TABLE "Profesor" (
  "id" serial PRIMARY KEY,
  "nombre" varchar NOT NULL,
  "correo" varchar,
  "especialidad" varchar
);

COMMENT ON COLUMN "Programa"."nombre" IS 'Nombre del programa.';

COMMENT ON COLUMN "Bootcamp"."nombre" IS 'Nombre del bootcamp.';

COMMENT ON COLUMN "Modulo"."nombre" IS 'Nombre del módulo.';

COMMENT ON COLUMN "Alumno"."nombre" IS 'Nombre completo del alumno.';

COMMENT ON COLUMN "Profesor"."nombre" IS 'Nombre completo del profesor.';

ALTER TABLE "Bootcamp" ADD FOREIGN KEY ("programa_id") REFERENCES "Programa" ("id");

ALTER TABLE "Modulo" ADD FOREIGN KEY ("profesor_id") REFERENCES "Profesor" ("id");

ALTER TABLE "BootcampModulo" ADD FOREIGN KEY ("bootcamp_id") REFERENCES "Bootcamp" ("id");

ALTER TABLE "BootcampModulo" ADD FOREIGN KEY ("modulo_id") REFERENCES "Modulo" ("id");

ALTER TABLE "Alumno" ADD FOREIGN KEY ("bootcamp_id") REFERENCES "Bootcamp" ("id");

ALTER TABLE "AlumnoModulo" ADD FOREIGN KEY ("alumno_id") REFERENCES "Alumno" ("id");

ALTER TABLE "AlumnoModulo" ADD FOREIGN KEY ("bootcamp_modulo_id") REFERENCES "BootcampModulo" ("id");
