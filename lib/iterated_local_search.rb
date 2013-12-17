require "iterated_local_search/version"

module IteratedLocalSearch
  class IteratedLocalSearch
    # gets distance between cities
    def euc_2d(c1, c2)
      Math.sqrt((c2[0] - c1[0]) ** 2.0 + (c2[1] - c1[1]) ** 2.0).round
    end

    # gets distance between two cities
    def cost(permutation, cities)
      distance = 0
      permutation.each_with_index do |c1, i|
        c2 = (i == (permutation.size - 1)) ? permutation[0] : permutation[i + 1]
        # +++ get distance between two cities
        distance += euc_2d cities[c1], cities[c2]
      end
      distance
    end

    # gets random permutation
    def random_permutation(cities)
      perm = Array.new(cities.size){|i| i}

      perm.each_index do |i|
        # +++ stays withing range, +- cancel each other
        r = rand(perm.size - i) + i
        perm[r], perm[i] = perm[i], perm[r]
      end
      perm
    end

    # gets reverse in range
    def stochastic_two_opt(permutation)
      perm = Array.new(permutation)
      c1, c2 = rand(perm.size), rand(perm.size)
      collection = [c1]
      collection << ((c1 == 0 ? perm.size - 1 : c1 - 1))
      collection << ((c1 == perm.size - 1) ? 0 : c1 + 1)
      c2 = rand(perm.size) while collection.include? (c2)
      c1, c2 = c2, c1 if c2 < c1
      # +++ reverses in range
      perm[c1...c2] = perm[c1...c2].reverse
      perm
    end

    # rejoins array
    def double_bridge_move(permutation)
      pos1 = 1 + (permutation.size / 4)
      pos2 = pos1 + 1 + rand(permutation.size / 4)
      pos3 = pos2 + 1 + rand(permutation.size / 4)
      p1 = permutation[0...pos1] + permutation[pos3...permutation.size]
      p2 = permutation[pos2...pos3] + permutation[pos1...pos2]
      p1 + p2
    end

    # does double bridge
    def perturbation(cities, best)
      candidate = {}
      candidate[:vector] = double_bridge_move best[:vector]
      candidate[:cost] = cost candidate[:vector], cities
      candidate
    end

    # does two opt
    def local_search(best, cities, max_no_improv)
      count = 0
      begin
        candidate = {:vector => stochastic_two_opt(best[:vector])}
        candidate[:cost] = cost(candidate[:vector], cities)
        count = (candidate[:cost] < best[:cost]) ? 0 : count + 1
        best = candidate if candidate[:cost] < best[:cost]
      end until count >= max_no_improv
      best
    end

    # does search
    def search(cities, max_iterations, max_no_improv)
      best = {}
      best[:vector] = random_permutation cities
      best[:cost] = cost best[:vector], cities
      best = local_search best, cities, max_no_improv
      max_iterations.times do |iter|
        candidate = perturbation cities, best
        candidate = local_search candidate, cities, max_no_improv
        best = candidate if candidate[:cost] < best[:cost]
        puts "iteration #{(iter + 1)}, best #{best[:cost]}"
      end
      best
    end
  end
end
