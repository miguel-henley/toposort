# Topological Sort - Delphi
Delphi/Pascal - topological sort implementation

Implementação em Delphi do algoritmo de ordenação topológica conforme descrito em https://en.wikipedia.org/wiki/Topological_sorting

Ha duas implementações.

1) Depth-First Search - implementada pela Unit uTopoSort.pas
2) Kahn - implementada pela Unit uTopoSortKahn.pas

A implementação por DFS (uTopoSort.pas) utiliza recursão - o que pode acarretar em erros de Stack Overflow se o grafo conter uma quantidade de nós muito grande.
<br><br>
A implementação utilizando o algoritmo de Kahn (uTopoSortKahn.pas) não utiliza recursão e sim uma estrutura de dados de Fila (TQueue).

O uso é muito simples. Imaginando um grafo como o abaixo:

![image](https://user-images.githubusercontent.com/43576141/227969953-6afec28f-84b2-4ac9-a022-7c8ba19010af.png)

e fazendo uso da classe TTopoSortKahn (definida em uTopoSortKahn.pas):

```
var
  lTopo: TTopoSortKahn;
  L: TList<String>;
begin
  lTopo := TTopoSortKahn.Create;

  // Primeiro os nós devem ser adicionados:
  lTopo.AddNode('5', nil);
  lTopo.AddNode('7', nil);
  lTopo.AddNode('3', nil);
  lTopo.AddNode('11', nil);
  lTopo.AddNode('8', nil);
  lTopo.AddNode('2', nil);
  lTopo.AddNode('9', nil);
  lTopo.AddNode('10', nil);

  // Agora as dependencias devem ser adicionadas: 
  // O primeiro parametro é o nó dependente.  O segundo parametro é o nó ao qual o primeiro depende.
  lTopo.AddDependency('5', '11');
  lTopo.AddDependency('7', '11');
  lTopo.AddDependency('7', '8');
  lTopo.AddDependency('3', '8');
  lTopo.AddDependency('3', '10');
  lTopo.AddDependency('11', '2');
  lTopo.AddDependency('11', '9');
  lTopo.AddDependency('11', '10');
  lTopo.AddDependency('8', '9');

  // Finalmente o metodo Sort deve ser chamado para realizar a ordenação topológica:
  L := lTopo.Sort;   
    
  // **Obteremos como resultado a seguinte sequencia: 9, 10, 2, 8, 11, 3, 7, 5**

  // lTopo.Free;
```
