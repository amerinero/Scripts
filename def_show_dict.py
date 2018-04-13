def show_dict (dic: dict, level=0):
	if not isinstance(dic,dict):
		raise ValueError('Llamada a show_dict con una variable que no es tipo dict')
	tabs=""
	for i in range(0,level):
		tabs = tabs + "\t"
	for clave in dic.keys():
		if isinstance(dic[clave],dict):
			print("%s%s > (dict)" %(tabs,clave))
			show_dict(dic[clave],level+1)
		elif isinstance(dic[clave],list):
			print("%s%s > (list)" %(tabs,clave))
			for index, item in enumerate(dic[clave]):
				if isinstance(item,dict):
					print("%s\tItem[%d] > (dict)" %(tabs,index))
					show_dict(item,level+2)
				else:
					print ("%s\t%s ==> %s" %(tabs,clave, dic[clave]))
		else:
			print ("%s%s ==> %s" %(tabs,clave, dic[clave]))