import re

resu = dict()


class Unificator:
    def __init__(self, file):
        inp = open(file, 'r')
        lines = []
        for line in inp:
            lines.append(line.split('=')[1].strip())
        m1 = re.findall(r'\(([0-9]+)\)', lines[0])
        m2 = re.findall(r'[a-zA-Z]+', lines[0])
        self.signature = {m2[i]: int(m1[i]) for i in range(len(m1))}
        self.vars = re.findall(r'[a-zA-Z]+', lines[1])
        self.substitution = {var: [] for var in self.vars}
        self.exist = True
        self.first, self.second = lines[2], lines[3]
        inp.close()

    def arguments(self, term):
        argarray = []
        st_index = term.find('(')
        bracketbalance = 0
        for i in range(len(term)):
            if term[i] == '(':
                bracketbalance += 1
            elif term[i] == ')':
                bracketbalance -= 1
            elif (term[i] == ',' and bracketbalance == 1):
                argarray.append(term[st_index + 1:i].strip())
                st_index = i
        argarray.append(term[st_index + 1:i].strip())
        return argarray

    def unificator(self, term1, term2):
        if term1 == term2:
            return term1
        if term1 in self.substitution.keys():
            self.substitution[term1].append(term2)
            return term2
        elif term2 in self.substitution.keys():
            self.substitution[term2].append(term1)
            return term1
        else:
            st = re.compile(r'[a-zA-Z]+')
            cons_name = st.match(term1).group(0)
            if cons_name == st.match(term2).group(0):
                args1 = self.arguments(term1)
                args2 = self.arguments(term2)
                uni_result = []
                for i in range(len(args1)):
                    uni_result.append(self.unificator(args1[i], args2[i]))
                return cons_name + '(' + ', '.join(uni_result) + ')'
            else:
                self.exist = False
                return ''
    def match(self, file):
        out = open(file, 'w')
        result = self.unificator(self.first, self.second)
        if not self.exist:
            out.write("unificator does not exist")
            out.close()
            return
        for i in self.substitution.keys():
            for j in range(len(self.substitution[i])):
                out.write(i + str(j) + '::=' + self.substitution[i][j] + '\n')
        out.write(result)
        out.close()

 # inp = open('input.txt', 'r')
# lines = []
# for line in inp:
#     lines.append(line.split('=')[1].strip())
# print(lines)
# m1 = re.findall(r'\(([0-9]+)\)',lines[0])
# m2 = re.findall(r'[a-zA-Z]+', lines[0])
# signature = {m2[i]: int(m1[i]) for i in range(len(m1))}
# vars = m2 = re.findall(r'[a-zA-Z]+', lines[1])
# substitution = {var:[] for var in vars}
# first, second = lines[2], lines[3]
# out = open('output.txt', 'w')
# uni = unificator(first, second)
# for i in substitution.keys():
#     if substitution[i] != []:
#         out.write(i + '::=' + substitution[i][0] + '\n')
# out.write(uni)
# inp.close()
# out.close()
