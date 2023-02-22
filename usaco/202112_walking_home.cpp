// http://www.usaco.org/index.php?page=viewproblem2&cpid=1157
//
// dynamic program
// [3, 4, 6] means 3 for 1-turn, 4 for 2-turn, 6 for 3-turn
// merge the first + [0, ... second] if with one turn.
//
// ([], []),   ([1], []),        ([1], []),                   ([1], []) 
// ([], [1]), ([1], [1]),      ([1,1], [1]),              ([1,2], [1])
// ([], [1]), ([1], [1,1]),   ([1,1,1], [1,1,1])      H
// ([], [1]), ([1], [1,2]),   ([1,1,2], [1,2,2,1]),  ([1,2,4,2,1], []),  


#include <iostream>
#include <string>
#include <vector>
#include <utility>

using namespace std;

void print_map(const vector<string>& m) {
  for (int i = 0; i < m.size(); i++) {
    cout << m[i] << endl;
  }
  cout << endl;
}

void print_vec(const vector<int>& v) {
  cout << "[";
  for (int elem : v) {
    cout << elem << ",";
  }
  cout << "]";
}

void print_ret_map(const vector<vector<pair<vector<int>, vector<int>>>>& ret) {
  for (int i = 0; i < ret.size(); i++) {
    for (int j = 0; j < ret[i].size(); j++) {
      auto curr = ret[i][j];
      cout << "(";
      print_vec(curr.first);
      cout << ", ";
      print_vec(curr.second);
      cout << ")\t| ";
    }
    cout << endl;
  }
}
			 

vector<int> merge(const vector<int>& same, const vector<int>& turn, int k) {
  vector<int> ret;
  for (int i = 0; i < same.size(); i++) {
    ret.push_back(same[i]);
  }
  for (int j = 0; j < turn.size(); j++) {
    if (j >= k) {
      // turn at most k times
      break;
    }
    if (j+1 < ret.size()) {
      ret[j+1] += turn[j];
    } else {
      ret.push_back(turn[j]);
    }
  }
  return move(ret);
}

int route(const vector<string>& m, int k) {
  int size = m.size();
  //
  //                            ([1,1,1], [1,1,1])
  // ([], [1]), ([1], [1,2]),   ([1,1,2], [1,2,2,1])

  vector<vector<pair<vector<int>, vector<int>>>> ret;
  for (int i = 0; i < size; i++) {
    vector<pair<vector<int>, vector<int>>> row;
    for (int j = 0; j < size; j++) {
      row.push_back(make_pair(vector<int>(), vector<int>()));
    }
    ret.push_back(row);
  }
  
  //                       | ([], [1])
  //                       | ([], [1])
  // ([1], []) | ([1], []) | ([], [ ])
  int a = (m[size-1][size-2] == '.') ? 1 : 0;
  ret[size-1][size-2].first.push_back(a);

  a = (m[size-2][size-1] == '.') ? 1 : 0;
  ret[size-2][size-1].second.push_back(a);

  for (int i = size-3; i >= 0; i--) {
    if (m[i][size-1] == '.') {
      for (auto elem : ret[i+1][size-1].second) {
	ret[i][size-1].second.push_back(elem);
      }
    } else {
      ret[i][size-1].second.push_back(0);
    }
  }
  for (int j = size-3; j >= 0; j--) {
    if (m[size-1][j] == '.') {
      for (auto elem : ret[size-1][j+1].first) {
	ret[size-1][j].first.push_back(elem);
      }
    } else {
      ret[size-1][j].first.push_back(0);
    }
  }

  for (int i = ret.size()-2; i >= 0; i--) {
    for (int j = ret[i].size()-2; j >= 0; j--) {
      if (m[i][j] == '.') {
	vector<int> x = merge(ret[i+1][j].first, ret[i+1][j].second, k);
	vector<int> y = merge(ret[i][j+1].second, ret[i][j+1].first, k);
	ret[i][j] = make_pair(x, y);
      } else {
	// remember to set ([0], [0])
	ret[i][j].first.push_back(0);
	ret[i][j].second.push_back(0);
      }
    }
  }

  //print_ret_map(ret);

  int r = 0;
  for (int i = 0; i < k; i++) {
    auto v = ret[0][0];
    if (i < v.first.size()) {
      r += v.first[i];
    }
    if (i < v.second.size()) {
      r += v.second[i];
    }
  }
  return r;
}
  

int main() {
  int n;
  cin >> n;
  for (int i = 0; i < n; i++) {
    int size, k;
    cin >> size >> k;
    vector<string> m;  // map
    for (int j = 0; j < size; j++) {
      string s;
      cin >> s;
      m.push_back(s);
    }

    //if (i != 7) continue;
    //cout << size << ", " << k << endl;
    //print_map(m);

    int r = route(m, k);
    cout << r << endl;
  }
}
