
from datetime import timedelta

from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from .models import Task


class TaskAPITests(APITestCase):

    def setUp(self):
        self.list_url = reverse("task-list")

        self.task = Task.objects.create(
            title="Learn Django",
            description="Complete TaskFlow backend",
            status="pending"
        )

        self.detail_url = reverse(
            "task-detail",
            args=[self.task.id]
        )

    # CREATE TESTS

    def test_create_task(self):
        data = {
            "title": "Learn Python",
            "description": "Practice Python",
            "status": "pending"
        }

        response = self.client.post(
            self.list_url,
            data,
            format="json"
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_201_CREATED
        )
        self.assertEqual(response.data["title"], "Learn Python")
        self.assertEqual(response.data["status"], "pending")

    def test_create_task_without_title(self):
        data = {
            "description": "Missing title",
            "status": "pending"
        }

        response = self.client.post(
            self.list_url,
            data,
            format="json"
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_400_BAD_REQUEST
        )

    def test_create_task_with_invalid_status(self):
        data = {
            "title": "Invalid task",
            "status": "invalid"
        }

        response = self.client.post(
            self.list_url,
            data,
            format="json"
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_400_BAD_REQUEST
        )

    def test_create_task_with_whitespace_title(self):
        response = self.client.post(
            self.list_url,
            {"title": "   ", "status": "pending"},
            format="json"
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_400_BAD_REQUEST
        )
        self.assertIn("title", response.data)

    def test_create_task_with_empty_title(self):
        response = self.client.post(
            self.list_url,
            {"title": "", "status": "pending"},
            format="json"
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_400_BAD_REQUEST
        )

    def test_create_task_without_description(self):
        response = self.client.post(
            self.list_url,
            {"title": "Task without description"},
            format="json"
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_201_CREATED
        )

    def test_create_task_default_status(self):
        response = self.client.post(
            self.list_url,
            {"title": "Default status task"},
            format="json"
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_201_CREATED
        )
        self.assertEqual(response.data["status"], "pending")

    def test_title_exceeding_max_length(self):
        response = self.client.post(
            self.list_url,
            {"title": "A" * 256},
            format="json"
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_400_BAD_REQUEST
        )

    def test_empty_description(self):
        response = self.client.post(
            self.list_url,
            {"title": "Empty description", "description": ""},
            format="json"
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_201_CREATED
        )

    def test_create_multiple_tasks(self):
        for i in range(3):
            response = self.client.post(
                self.list_url,
                {"title": f"Task {i}"},
                format="json"
            )

            self.assertEqual(
                response.status_code,
                status.HTTP_201_CREATED
            )

        response = self.client.get(self.list_url)

        self.assertEqual(
            response.status_code,
            status.HTTP_200_OK
        )
        self.assertEqual(len(response.data), 4)

    # READ TESTS

    def test_list_tasks(self):
        response = self.client.get(self.list_url)

        self.assertEqual(
            response.status_code,
            status.HTTP_200_OK
        )

    def test_retrieve_task(self):
        response = self.client.get(self.detail_url)

        self.assertEqual(
            response.status_code,
            status.HTTP_200_OK
        )
        self.assertEqual(response.data["title"], "Learn Django")

    def test_retrieve_nonexistent_task(self):
        response = self.client.get(
            reverse("task-detail", args=[99999])
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_404_NOT_FOUND
        )

    def test_retrieve_task_after_update(self):
        self.client.patch(
            self.detail_url,
            {"title": "New task title"},
            format="json"
        )

        response = self.client.get(self.detail_url)

        self.assertEqual(
            response.status_code,
            status.HTTP_200_OK
        )
        self.assertEqual(response.data["title"], "New task title")

    def test_retrieve_task_after_delete(self):
        self.client.delete(self.detail_url)

        response = self.client.get(self.detail_url)

        self.assertEqual(
            response.status_code,
            status.HTTP_404_NOT_FOUND
        )

    def test_created_at_is_generated(self):
        response = self.client.get(self.detail_url)

        self.assertEqual(
            response.status_code,
            status.HTTP_200_OK
        )
        self.assertIsNotNone(response.data["created_at"])

    # UPDATE TESTS

    def test_update_task(self):
        data = {
            "title": "Updated task",
            "description": "Updated description",
            "status": "completed"
        }

        response = self.client.put(
            self.detail_url,
            data,
            format="json"
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_200_OK
        )
        self.assertEqual(response.data["title"], "Updated task")
        self.assertEqual(response.data["status"], "completed")

    def test_partial_update_task(self):
        response = self.client.patch(
            self.detail_url,
            {"status": "completed"},
            format="json"
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_200_OK
        )
        self.assertEqual(response.data["status"], "completed")

    def test_patch_task_with_invalid_status(self):
        response = self.client.patch(
            self.detail_url,
            {"status": "invalid"},
            format="json"
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_400_BAD_REQUEST
        )

    def test_put_task_with_invalid_status(self):
        response = self.client.put(
            self.detail_url,
            {
                "title": "Updated task",
                "description": "Updated",
                "status": "invalid"
            },
            format="json"
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_400_BAD_REQUEST
        )

    def test_update_nonexistent_task(self):
        response = self.client.patch(
            reverse("task-detail", args=[99999]),
            {"title": "Updated"},
            format="json"
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_404_NOT_FOUND
        )

    def test_updated_at_changes_after_update(self):
        old_updated_at = self.task.updated_at

        # Move the timestamp back to make the comparison deterministic.
        Task.objects.filter(pk=self.task.pk).update(
            updated_at=old_updated_at - timedelta(seconds=5)
        )

        response = self.client.patch(
            self.detail_url,
            {"title": "Changed title"},
            format="json"
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_200_OK
        )

        self.task.refresh_from_db()

        self.assertGreater(
            self.task.updated_at,
            old_updated_at
        )

    # DELETE TESTS

    def test_delete_task(self):
        response = self.client.delete(self.detail_url)

        self.assertEqual(
            response.status_code,
            status.HTTP_204_NO_CONTENT
        )

        self.assertFalse(
            Task.objects.filter(id=self.task.id).exists()
        )

    def test_delete_nonexistent_task(self):
        response = self.client.delete(
            reverse("task-detail", args=[99999])
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_404_NOT_FOUND
        )
