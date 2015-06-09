// multi-dimensional spatial Euclid distance square
//
// Much inspiration has been gained from the kmeans-vector package on
// Hackage.
//
// --
//
// compiled input @ data/trivial.in
// output @ data/trivial.out
// compiled input @ data/100.in
// output @ data/100.out

fun real euclid_dist_2([real,numdims] pt1, [real,numdims] pt2) =
  reduce(+, 0.0, map(pow 2.0, zipWith(-, pt1, pt2)))

fun {int,real} closest_point({int,real} p1, {int,real} p2) =
  let {_,d1} = p1 in
  let {_,d2} = p2 in
  if d1 < d2 then p1 else p2

fun int find_nearest_point([[real,nfeatures],npoints] pts, [real,nfeatures] pt) =
  let {i, _} = reduce(closest_point,
                      {0, euclid_dist_2(pt,pts[0])},
                      zip(iota(npoints),
                          map(euclid_dist_2(pt), pts))) in
  i

fun [real,nfeatures] add_centroids([real,nfeatures] x, [real,nfeatures] y) =
  zipWith(+, x, y)

fun [[real,nfeatures],nclusters]
  centroids_of(int nclusters, [[real,nfeatures],npoints] feature, [int,npoints] membership) =
  let blank = replicate(nclusters, {copy(replicate(nfeatures, 0.0)), 0}) in
  let incrs =
    zipWith(fn [{[real,nfeatures],int},nclusters] ([real,nfeatures] feature, int cluster) =>
              let a = copy(blank) in
              let a[cluster] = {feature,1} in
              a,
            feature, membership) in
  let {cluster_sums, features_in_clusters} =
    unzip(reduce(fn [{[real,nfeatures],int},nclusters] ([{[real,nfeatures],int},nclusters] acc,
                                                        [{[real,nfeatures],int},nclusters] x) =>
                   zipWith(fn {[real,nfeatures],int} ({[real,nfeatures],int} x,
                                                      {[real,nfeatures],int} y) =>
                             let {x_a, x_b} = x in
                             let {y_a, y_b} = y in
                             {add_centroids(x_a, y_a), x_b + y_b},
                           acc, x),
                 blank, incrs)) in
  zipWith(fn [real,nfeatures] ([real,nfeatures] cluster_sum,
                               int features_in_cluster) =>
            map(/toFloat(features_in_cluster), cluster_sum),
          cluster_sums, features_in_clusters)

fun {[[real]], [int], int}
  main(int threshold,
       int nclusters,
       int max_iterations,
       [[real,nfeatures],npoints] feature) =
  // Assign arbitrary initial cluster centres.
  let cluster_centres = map(fn [real] (int i) =>
                              feature[i],
                            iota(nclusters)) in
  // Also assign points arbitrarily to clusters.
  let membership = map(% nclusters, iota(npoints)) in
  let delta = threshold + 1 in
  let i = 0 in
  loop ({membership, cluster_centres, delta, i}) = while delta > threshold && i < max_iterations do
    // For each point, find the cluster with the closest centroid.
    let new_membership = map(find_nearest_point(cluster_centres), feature) in
    // Then, find the new centres of the clusters.
    let new_centres = centroids_of(nclusters, feature, new_membership) in
    let delta = reduce(+, 0, map(fn int (bool b) =>
                                   if b then 0 else 1,
                                 zipWith(==, membership, new_membership))) in
    {new_membership, new_centres, delta, i+1} in
  {cluster_centres, membership, i}
