extern crate rand;

use std::collections::{HashMap, HashSet};
use std::env::args;
use std::fs::read_to_string;

use rand::thread_rng;
use rand::seq::SliceRandom;

fn main() {
    let data = read_to_string(args().nth(1).unwrap()).unwrap();
    let mut dists = HashMap::new();
    let mut points = HashSet::new();

    for line in data.lines() {
        let parts: Vec<_> = line.split(",").collect();
        assert_eq!(parts.len(), 3);
        let (a, b, dist) = (parts[0], parts[1], parts[2]);
        if let Ok(dist) = dist.parse::<f64>() {
            dists.insert((a, b), dist);
        }
        points.insert(a);
        points.insert(b);
    }

    let mut route: Vec<_> = points.iter().collect();
    route.shuffle(&mut thread_rng());

    let mut temp = 1000.;
    let cooling_factor = 0.003;
    let curr_distance: f64 = route.as_slice().windows(2).map(|i| dists[&(*i[0], *i[1])]).sum();

    while temp > 1. {
        let old_distance = 

        temp *= 1. - cooling_factor;
    }



    println!("Done");
}
