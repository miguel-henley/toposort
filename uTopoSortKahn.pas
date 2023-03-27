unit uTopoSortKahn;

// Versao 1.0.0
// Ordenacao Topologica usando o Algorithmo de Kahn
// Esse algoritmo esta' descrito em:
//     https://en.wikipedia.org/wiki/Topological_sorting
// Nota: Em alguns pontos da implementacao foram utilizadas algumas variaveis com
// pouco siginificado, tais como: L, S, n, m - ou seja - incompativel com as praticas
// de codigo limpo. A decisao por tais variaveis foi por tornar o codigo proximo
// ao descrito pelo algoritmo.

interface

uses
  Generics.Collections;

type
  TTopoSortKahn = class
    strict private type TNode = class
      strict private
        FId: String;
        FAny: TObject;
        FIncoming: TList<TNode>;
        FOutcoming: TList<TNode>;
        FCountIncoming: Integer;
        FCountOutcoming: Integer;
    public
       property Id: String read FId write FId;
       property Any: TObject read FAny write FAny;
       property IncomingNode: TList<TNode> read FIncoming;
       property OutcomingNode: TList<TNode> read FOutcoming;

       property CountIncoming: Integer read FCountIncoming write FCountIncoming;
       property CountOutcoming: Integer read FCountOutcoming write FCountOutcoming;

       constructor Create(prstId: String; prAny: TObject);
       destructor Destroy; override;
    end;

    private
      FLstNode: TList<TNode>;
      FDctNode: TDictionary<String, TNode>;
      L: TList<String>;
      S: TQueue<TNode>;
      FRaiseExcepctionIfDependencyAlreadyExist: boolean;
      function DependencyAlreadyExist(fromNodeId: TNode; toNodeId: TNode): boolean;
    public
      function AddNode(prstId: String; prAny: TObject): TTopoSortKahn;
      function AddDependency(fromNodeId: String; toNodeId: String): TTopoSortKahn;
      function Sort: TList<String>;
      constructor Create;
      destructor Destroy; override;

      property RaiseExceptionIfDependencyAlreadyExist: boolean
        read FRaiseExcepctionIfDependencyAlreadyExist write FRaiseExcepctionIfDependencyAlreadyExist;
  end;

implementation

uses
  SysUtils;

{ TTopoSortKahn.TNode }

constructor TTopoSortKahn.TNode.Create(prstId: String; prAny: TObject);
begin
  inherited Create;
  FId := prstId;
  FAny := prAny;
  FIncoming := TList<TNode>.Create;
  FOutcoming := TList<TNode>.Create;
end;

destructor TTopoSortKahn.TNode.Destroy;
begin
  FIncoming.Free;
  FOutcoming.Free;
  inherited;
end;

{ TTopoSortKahn }

function TTopoSortKahn.AddDependency(fromNodeId, toNodeId: String): TTopoSortKahn;
var
  lNodeFrom: TNode;
  lNodeTo: TNode;
begin
  lNodeFrom := FDctNode[fromNodeId];
  lNodeTo := FDctNode[toNodeId];

  if DependencyAlreadyExist(lNodeFrom, lNodeTo) then
    if FRaiseExcepctionIfDependencyAlreadyExist then
      raise Exception.Create('Dependency already exist')
    else
      Exit;

  lNodeFrom.OutcomingNode.Add(lNodeTo);
  lNodeTo.IncomingNode.Add(lNodeFrom);
end;

function TTopoSortKahn.AddNode(prstId: String; prAny: TObject): TTopoSortKahn;
var
  lNode: TNode;
begin
  lNode := TNode.Create(prstId, prAny);
  FLstNode.Add(lNode);
  FDctNode.Add(prstId, lNode);
  Result := Self;
end;

function TTopoSortKahn.DependencyAlreadyExist(fromNodeId,
  toNodeId: TNode): boolean;
var
  lNode: TNode;
begin
  for lNode in fromNodeId.OutcomingNode do
    if toNodeId.Id = lNode.Id then
      Exit(true);

  Exit(false);
end;

constructor TTopoSortKahn.Create;
begin
  inherited;
  FLstNode := TList<TNode>.Create;
  FDctNode := TDictionary<String, TNode>.Create;
  S := TQueue<TNode>.Create;
end;

destructor TTopoSortKahn.Destroy;
var
  lNode: TNode;
begin
  for lNode in FLstNode do
    lNode.Free;

  FLstNode.Free;
  FDctNode.Free;
  L.Free;
  inherited;
end;

function TTopoSortKahn.Sort: TList<String>;
var
  lNode: TNode;
  n, m: TNode;
begin
  for lNode in FLstNode do
  begin
    lNode.CountIncoming := lNode.IncomingNode.Count;
    lNode.CountOutcoming := lNode.OutcomingNode.Count;

    if lNode.CountIncoming = 0 then
      S.Enqueue(lNode);
  end;

  if L = nil then
    L := TList<String>.Create
  else
    L.Clear;

  while S.Count <> 0 do
  begin
    n := S.Dequeue;
    L.Insert(0, n.Id);

    for m in n.OutcomingNode do
    begin
      m.CountIncoming := m.CountIncoming - 1;

      if m.CountIncoming = 0 then
        S.Enqueue(m);
    end;

  end;

  // Check and raise exception if cycle is detected
  for lNode in FLstNode do
  begin
    if lNode.CountIncoming <> 0 then
      raise Exception.Create('Cycle detected');
  end;

  Result := L;
end;


end.
