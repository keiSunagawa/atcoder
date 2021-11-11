# https://atcoder.jp/contests/kupc2021/tasks/kupc2021_l
defmodule GEdge do
  defstruct to: 0, size: 1
end

defmodule GNode do
  defstruct id: 0, edge: []
end

defmodule Graph do
  defstruct nodes: []

  defp serch_adjoin(graph, pos_node, footprint) do
    # 隣接ノードで進行可能かつ、足跡に含まれない新しいノード(TODO エッジのsizeも計算に含める)
    graph.nodes
    |> Enum.filter(fn n ->
      Enum.any?(pos_node.edge, fn e -> e.to == n.id && ! Enum.any?(footprint, &(e.to == &1)) end)
    end)
  end
  def serch_adjoin(graph, pos) do
    pos_node =
      graph.nodes
      |> Enum.find(fn n -> n.id == pos end)
    serch_adjoin(graph, pos_node, [pos])
  end
  defp search_oni_pos(graph, pos_node, distance, footprint) do
    rinsetu = serch_adjoin(graph, pos_node, footprint)
    new_dis = distance - 1
    if new_dis <= 0 do
      rinsetu
    else
      # alert 末尾再帰ではない
      rinsetu |> Enum.flat_map(fn r ->
        new_fp = [r.id | footprint]
        search_oni_pos(graph, r, new_dis, new_fp)
      end
      )
    end
  end
  # 鬼の位置を探す
  def search_oni(graph, pos, distance) do
    pos_node =
      graph.nodes
      |> Enum.find(fn n -> n.id == pos end)
    oni_pos = search_oni_pos(graph, pos_node, distance, [pos_node.id])
    oni_pos
  end

  def oni_distance(graph, pos_node, oni_pos_node, distance, footprint) do
    adjoin = serch_adjoin(graph, pos_node, footprint)
    new_dis = distance + 1
    adjoin |> Enum.flat_map(fn r ->
      new_fp = [r.id | footprint]
      if r.id == oni_pos_node.id, do: [new_dis], else: oni_distance(graph, r, oni_pos_node, new_dis, new_fp)
    end)
  end

  def oni_distance(graph, pos, oni_pos_node) do
    pos_node =
      graph.nodes
      |> Enum.find(fn n -> n.id == pos end)
    # 初期のfootprintには自分の初期位置を追加する
    dis_list = oni_distance(graph, pos_node, oni_pos_node, 0, [pos_node.id])
    Enum.min(dis_list)
  end
end

defmodule Init do
  def init_state_1() do
    g = %Graph{
      nodes: [
        %GNode{id: 1, edge: [ %GEdge{to: 2} ]},
        %GNode{id: 2, edge: [ %GEdge{to: 1}, %GEdge{to: 3} ]},
        %GNode{id: 3, edge: [ %GEdge{to: 2}, %GEdge{to: 4} ]},
        %GNode{id: 4, edge: [ %GEdge{to: 3}, %GEdge{to: 5} ]},
        %GNode{id: 5, edge: [ %GEdge{to: 4} ]},
      ]
    }
    s = 1
    d = 4
    {g, s, d}
  end
  def init_state_2() do
    g = %Graph{
      nodes: [
        %GNode{id: 1, edge: [ %GEdge{to: 2}, %GEdge{to: 4}, %GEdge{to: 6} ]},
        %GNode{id: 2, edge: [ %GEdge{to: 1}, %GEdge{to: 3} ]},
        %GNode{id: 3, edge: [ %GEdge{to: 2}, %GEdge{to: 5} ]},
        %GNode{id: 4, edge: [ %GEdge{to: 1}, %GEdge{to: 5} ]},
        %GNode{id: 5, edge: [ %GEdge{to: 4}, %GEdge{to: 3} ]},
        %GNode{id: 6, edge: [ %GEdge{to: 1}]},
      ]
    }
    s = 1
    d = 2
    {g, s, d}
  end
end
defmodule TagGame do
  # 鬼と自分の位置から次の行動を決定する, result -> {:move, n} or :no_move
  # 鬼から確実に遠ざかる位置のみを決定
  def next_move(graph, pos, oni_pos_nodes, pre_dis) do
    # 移動可能なnodeを取得
    adjon = Graph.serch_adjoin(graph, pos)
    # それぞれをposとしたときの鬼との距離を計測
    moveable = adjon |> Enum.map(fn r ->
      # すべとの鬼仮定位置を計算し、最小の値をとる。一部の鬼との距離が離れても他の鬼との距離が縮まってしまう可能性を防ぐため
      min_dis = oni_pos_nodes |> Enum.map(fn o -> Graph.oni_distance(graph, r.id, o) end) |> Enum.min()
      {r, min_dis}
    end)
    # 一番遠かったものを返却
    nexts = moveable |> Enum.reduce([], fn ({m, dis}, acc) ->
      if Enum.empty?(acc) do
        [{m, dis}]
      else
        [{_h, h_dis} | _t] = acc
        cond do
          h_dis < dis -> [{m, dis}]
          h_dis == dis -> [{m, dis} | acc]
          true -> acc
         end
      end
    end)
    # 以下の場合現在の位置から移動しない
    # - 一番遠かったものが現在の鬼への距離より短い
    # - 一番遠かった距離が複数存在する
    case nexts |> Enum.filter(fn {_n, d} -> pre_dis < d end) do
      [] -> pos
      [{a, _d}] -> a.id
      _otherwise -> pos
    end
  end

  def main() do
    {graph, start, distance} = Init.init_state_2
    onis = Graph.search_oni(graph, start, distance)
    next = next_move(graph, start, onis, distance)
    {start, next, onis}
  end
end
