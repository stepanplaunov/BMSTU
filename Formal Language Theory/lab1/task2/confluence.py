class ConfluenceChecker:
    def __init__(self, file):
        inp = open(file, 'r')
        self.data = []
        for line in inp:
            self.data.append(line.strip().split(" ")[0])
        self.answ = []
        inp.close()
    def check_prefix(self, left, right):
        string = left + right
        n = len(string)
        prefix = [0] * n
        for i in range(1, n):
            j = prefix[i - 1]
            while j > 0 and string[i] != string[j]:
                j = prefix[j - 1]
            if string[i] == string[j]:
                j += 1
            prefix[i] = j
        if prefix[-1] > 0:
            return False
        else:
            return True
    def check_confluence(self):
        result = True
        data = self.data
        for i in range(len(data)):
            for second in data:
                if data[i] == second:
                    result = result and self.check_prefix(data[i], '')
                else:
                    result = result and self.check_prefix(data[i], second)

                if result == False:
                    self.answ = [data[i], second]
                    return 'The system is probably not confluent (there is an overlap of ' + self.answ[0] + ' with ' + self.answ[1] + ')'
        if result:
            return 'Confluent system'
