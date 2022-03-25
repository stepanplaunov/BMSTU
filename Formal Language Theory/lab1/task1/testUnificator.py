import unittest
from Unificatorv2 import Unificator
class TestUnificator(unittest.TestCase):
    def setUp(self):
        pass
    def match(self, i):
        unificator = Unificator('tests/input' + str(i) + '.txt')
        unificator.match('tests/output' + str(i) + '.txt')
        outfile = open('tests/output' + str(i) + '.txt', 'r')
        answerfile = open('tests/answer' + str(i) + '.txt', 'r')
        out = outfile.read()
        answer = answerfile.read()
        outfile.close()
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
