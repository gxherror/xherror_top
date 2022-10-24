---
title: "范型"
description: 学习
date: 2022-10-19T14:08:03Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
  - DB
tags:
---
## Normalization Theory

- Decide whether a particular relation R is in “good”  form
- If R is not in “good”  form, decompose it into  set of relations {R1, R2, ..., Rn} such that each R is in good form, and decomposition is a lossless

## Lossless Decomposition

1. ![8ad8d8ac9cc1f1ff96ce23cdcc886eef.png](/images/8ad8d8ac9cc1f1ff96ce23cdcc886eef.png)
2. at least one of the following dependencies is in F+:
   -  R1 ∩  R2 →  R1 
   -  R1 ∩  R2 →  R2
3. Lossy decomposition example:
![85863350be0c5e2afe34b6e2e628378a.png](/images/85863350be0c5e2afe34b6e2e628378a.png)

# Functional Dependencies

The functional dependency `α→β` holds on R if `t1[α] = t2 [α]   ⇒      t1[β ]  = t2 [β ]` 

>Note:  A specific instance of a relation schema may satisfy a functional dependency even if the functional dependency does not hold on all legal instances

### closure of a Set of FD

The set of all functional dependencies logically implied by F is the **closure of F**(F+)

### trivial FD

In general, α  →  β  is trivial if β  ⊆  α

## Dependency Preservation

  A decomposition that makes it computationally hard to enforce functional dependency is said to be NOT dependency preserving.

### is_DP

- A  decomposition is dependency preserving,  if `(F1 ∪  F2 ∪  … ∪  Fn )+ = F +`

  - exponential time

  

## Closure of Attribute Sets

Given a set of attributes α,  define the closure  of α  under F (denoted by α+) as the set of attributes that are functionally 
determined by α  under **F**

- Testing for SK
- Testing functional dependencies
  - To check if a functional dependency α  →  β  holds (or, in other words, is in F+), just check if β  ⊆  α+
- Computing closure of F

# 1NF

![3862c444ac848e1a2638c409b7e33aae.png](/images/3862c444ac848e1a2638c409b7e33aae.png)

# 第二范式

第二范式（2NF）要求实体的全部属性完全依赖于主关键字。所谓完全依赖是指不能存在仅依赖主关键字一部分的属性。

# 第三范式

满足第三范式（3NF）必须先满足第二范式（2NF）。简而言之，第三范式（3NF）要求非主键列必须直接依赖于主键，不能存在传递依赖
![c8e9ce78bf3f9e5f6c23003437823509.png](/images/c8e9ce78bf3f9e5f6c23003437823509.png)

# BCNF

- It is not always possible to achieve both BCNF and dependency preservation 
- BCNF is lossless-join decomposition

### is_BCNF

all FD in F+ of the form `α→β`

- α  →  β    is trivial (i.e., β  ⊆  α) 
- α  is a SK for R

### BCNF_decomposition

`α  →β` be the FD that causes a violation of BCNF
decompose R into: `(α  U β  )` +`( R - ( β  - α  ) )`

### Redundancy in BCNF

![85747e2bcda1db61263dcaf91941bb5e.png](/images/85747e2bcda1db61263dcaf91941bb5e.png)


# 3NF

3NF is a minimal relaxation of BCNF to ensure dependency preservation

### is_3NF

if for all: `α  →  β`  in `F` (JUST F)

- α  →  β  is trivial (i.e., β  ∈  α) 
- α  is a SK for R 
- Each attribute A in β  – α  is contained in a candidate key for R.
  - Testing for 3NF has been shown to be NP-hard

### is_3NF in polynomial time 

**TODO**

### Redundancy in 3NF

![eafd0d85ccc6e054be2975c4ac75a8c9.png](/images/eafd0d85ccc6e054be2975c4ac75a8c9.png)

- Repetition of information 
- Need to use null values (e.g., to represent the relationship l2, k2 where there is no corresponding value for J)

## Extraneous Attributes

An attribute of a functional dependency  in F is extraneous if we can remove it without changing F+

### Testing if an Attribute is Extraneous

To test if attribute A ∈  β  is extraneous in β 

- Consider the set:  F' = (F – {α  →  β}) ∪  {α  →(β  – A)}, 
- check that α+ contains A; if it does, A is extraneous in β 

To test if attribute A ∈  α  is extraneous in α 

- Let γ  = α  – {A}. Check if γ    →  β    can be inferred  from F. 
  - Compute γ+ using the dependencies in F
  - If γ+  includes all attributes in β  then , A is extraneous in α

## Canonical Cover

A canonical cover for F is a set of dependencies Fc such that 

- No functional dependency in Fc contains an extraneous attribute
- Each left side of functional dependency in Fc is unique. That is, there are no two dependencies in Fc



## Multivalued Dependencies (MVDs)

The multivalued dependency `α  →→  β` holds on R if in any legal relation r(R), for all pairs for tuples t1 and t2 in r such that t1[α] = t2 [α], there exist tuples t3 and t4 in r such that: 
![fbf1a42310235c89bf176d8326c5f352.png](/images/fbf1a42310235c89bf176d8326c5f352.png)

- If a relation r fails to satisfy a given multivalued dependency, we can construct a relations r′    that does satisfy the multivalued dependency by adding tuples to r. 



# 4NF

A relation schema R is in 4NF with respect to a set D of functional and multivalued dependencies if for all multivalued dependencies in D+ of the form `α  →→  β`, at least one of the following hold:

- α  →→  β  is trivial (i.e., β  ⊆  α  or α  ∪  β  = R) 
- α  is a SK for schema R

> If a relation is in 4NF it is in BCNF

# Others

## ER Model and Normalization

- When an E-R diagram is carefully designed, identifying all entities correctly, the tables generated from the E-R diagram should not need further normalization.
- Good design would have made  (FD from non-key attributes of an entity to other attributes of the entity) an entity

## Denormalization for Performance

- May want to use non-normalized schema for performance
  - display join of course with prereq

- Alternative 1:  Use denormalized relation
  - faster lookup
  - extra space and extra execution time for updates
  - extra coding work for programmer and possibility of error in extra code
- Alternative 2: use a materialized view
  - Benefits and drawbacks same as above, except no extra coding work for programmer and avoids possible errors

## Modeling Temporal Data

**Temporal data** have an association time interval during which the data are valid

https://www.cnblogs.com/guanghe/p/10784270.html