unit uTopoSort;

// Versao 1.0.0
// Implementacao do Algoritmo descrito em:
// https://en.wikipedia.org/wiki/Topological_sorting
// Esse algoritmo trabalha com recursividade, então para um numero
// muito grande de Nós, podemos ocasionar StackOverflow.
// Como alternativa foi implementado tambem a ordenacao topologica
// utilizando o Algoritmo de Kahn (implementado em outra unit: uTopoSortKahn.pas)

interface

uses
  Generics.Collections;

type
  TTopoSort = class
    strict private type TNodeStatus = (vsUnMarked, vsTemporary, vsPermanentMark);
    strict private type TNode = class
      strict private
        FId: String;
        FAny: TObject;
        FIncoming: TList<TNode>;
        FOutcoming: TList<TNode>;
        FStatus: TNodeStatus;
    public
       property Id: String read FId write FId;
       property Any: TObject read FAny write FAny;
       property IncomingNode: TList<TNode> read FIncoming;
       property OutcomingNode: TList<TNode> read FOutcoming;
       property Status: TNodeStatus read FStatus write FStatus;
       constructor Create(prstId: String; prAny: TObject);
       destructor Destroy; override;
    end;

    private
      FLstNode: TList<TNode>;
      FDctNode: TDictionary<String, TNode>;
      L: TList<String>;
      function GetAnyNodeWithoutPermanentMark: TNode;
      procedure Visit(n: TNode);
    public
      function AddNode(prstId: String; prAny: TObject): TTopoSort;
      function AddDependency(fromNodeId: String; toNodeId: String): TTopoSort;
      function Sort: TList<String>;
      constructor Create;
      destructor Destroy; override;
  end;

implementation

uses
  SysUtils;

{ TTopoSort.TNode }

constructor TTopoSort.TNode.Create(prstId: String; prAny: TObject);
begin
  inherited Create;
  FId := prstId;
  FAny := prAny;
  FIncoming := TList<TNode>.Create;
  FOutcoming := TList<TNode>.Create;
  FStatus := vsUnMarked;
end;

destructor TTopoSort.TNode.Destroy;
begin
  FIncoming.Free;
  FOutcoming.Free;
  inherited;
end;

{ TTopoSort }

function TTopoSort.AddDependency(fromNodeId, toNodeId: String): TTopoSort;
var
  lNodeFrom: TNode;
  lNodeTo: TNode;
begin
  lNodeFrom := FDctNode[fromNodeId];
  lNodeTo := FDctNode[toNodeId];
  lNodeFrom.OutcomingNode.Add(lNodeTo);
  lNodeTo.IncomingNode.Add(lNodeFrom);
end;

function TTopoSort.AddNode(prstId: String; prAny: TObject): TTopoSort;
var
  lNode: TNode;
begin
  lNode := TNode.Create(prstId, prAny);
  FLstNode.Add(lNode);
  FDctNode.Add(prstId, lNode);
  Result := Self;
end;

constructor TTopoSort.Create;
begin
  inherited;
  FLstNode := TList<TNode>.Create;
  FDctNode := TDictionary<String, TNode>.Create;
end;

destructor TTopoSort.Destroy;
var
  lNode: TNode;
begin
  for lNode in FLstNode do
    lNode.Free;

  FLstNode.Free;
  FDctNode.Free;
  FreeAndNil(L);
  inherited;
end;

function TTopoSort.GetAnyNodeWithoutPermanentMark: TNode;
var
  lNode: TNode;
begin
  Result := nil;

  for lNode in FLstNode do
    if lNode.Status <> vsPermanentMark then
      Exit(lNode);
end;

function TTopoSort.Sort: TList<String>;
var
  lNode: TNode;
begin
  for lNode in FLstNode do
    lNode.Status := vsUnMarked;

  if L = nil then
    L := TList<String>.Create
  else
    L.Clear;

  lNode := GetAnyNodeWithoutPermanentMark;

  while lNode <> nil do
  begin
    Visit(lNode);
    lNode := GetAnyNodeWithoutPermanentMark;
  end;

  Result := L;
end;

procedure TTopoSort.Visit(n: TNode);
var
  m: TNode;
begin
  if n.Status = vsPermanentMark then
    Exit;

  if n.Status = vsTemporary then
    raise Exception.Create('Cycle detected in Graph. Check Node ' + n.Id);

  n.Status := vsTemporary;

  for m in n.OutcomingNode do
    Visit(m);

  n.Status := vsPermanentMark;
  L.Add(n.Id);
end;

end.
