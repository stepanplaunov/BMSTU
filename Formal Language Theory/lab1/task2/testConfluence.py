import unittest
from confluence import ConfluenceChecker
class TestUnificator(unittest.TestCase):
    def setUp(self):
        pass
    def match(self, i):
        con = ConfluenceChecker('tests/input' + str(i) + '.txt')
        out = con.check_confluence()
        answerfile = open('tests/answer' + str(i) + '.txt', 'r')
        answer = answerfile.read()
        answerfile.close()
        return [out, answer]
    def test_0(self):
        match = self.match(0)
        self.assertEqual(*match)
    def test_1(self):
        match = self.match(1)
        self.assertEqual(*match)
    def test_2(self):
        match = self.match(2)
        self.assertEqual(*match)
    def test_3(self):
        match = self.match(3)
        self.assertEqual(*match)
if __name__ == "__main__":
    unittest.main()
