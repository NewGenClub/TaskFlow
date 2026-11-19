TaskFlow – Phase 1 Backend

1. Database Changes

Database: PostgreSQL (taskflow_db)

Table: tasks_task

Column

Type

Description

id

BigInteger

Primary key

title

VARCHAR(255)

Required task title

description

TEXT

Optional description

status

VARCHAR(20)

pending / completed

created_at

TIMESTAMP

Automatically generated

updated_at

TIMESTAMP

Automatically updated

2. API Endpoints

Base URL: /api/v1/tasks/

Method

Endpoint

Description

GET

/api/v1/tasks/

List all tasks

POST

/api/v1/tasks/

Create a task

GET

/api/v1/tasks/{id}/

Retrieve a task

PUT

/api/v1/tasks/{id}/

Update entire task

PATCH

/api/v1/tasks/{id}/

Partially update task

DELETE

/api/v1/tasks/{id}/

Delete a task

3. Validation

Title is required and cannot contain only whitespace.

Status accepts only pending or completed.

Invalid requests return 400 Bad Request.

Non-existent task IDs return 404 Not Found.

4. Configuration

Database credentials and connection settings are loaded from the root .env file.

Environment variables:

DB_NAME

DB_USER

DB_PASSWORD

DB_HOST

DB_PORT