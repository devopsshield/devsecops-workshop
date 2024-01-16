from django.test import TestCase

class TestRegisterView(TestCase):

    def test_register_view_returns_OK(self):
        response = self.client.get('/register')
        self.assertEqual(response.status_code,200)

class TestRegisterFunction(TestCase):

    def test_register_function_returns_expected_result(self):
        data = {'username': 'John', 'email': 'John@gmail.com', 'password1': 'secret123', 'password2': 'secret123'}
        response = self.client.post("/register", data=data)
        self.assertEquals(response.status_code, 200)
