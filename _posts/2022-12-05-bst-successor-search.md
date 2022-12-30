---
layout: post
title: BST Successor Search
published: yes
tags:
  - perl
  - binary tree
  - inorder
  - successor
  - Moo
  - Iterator::Simple
---
As I was designing interview questions for our hiring, I run into [a coding interview video with binary tree](https://www.youtube.com/watch?v=jma9hFQSCDk). The task caught my attention, so I put together quick solution in perl using [Moo](https://metacpan.org/pod/Moo) for classes and [Iterator::Simple](https://metacpan.org/pod/Iterator::Simple) for in-order traversal.

First, I needed a tree building block.

```perl
package Node {
    use Moo;

    has key   => (is => 'ro');
    has left  => (is => 'rwp');
    has right => (is => 'rwp');
}
```

Then a tree class that would allow construction and insert new node.

```perl
package BST {
    use Moo;
    use Function::Parameters;
    use Iterator::Simple qw(iterator);

    has root => (is => 'rwp');

    method insert($key) {
        my $new_node = Node->new(key => $key);
        $self->_set_root($self->_insert_under($self->root, $new_node));
    }

    method _insert_under($root, $new_node) {
        return $new_node unless defined $root;

        if($root->key > $new_node->key) {
            $root->_set_left( $self->_insert_under($root->left,  $new_node));
        }
        else {
            $root->_set_right($self->_insert_under($root->right, $new_node));
        }
        return $root;
    }
}
```

Usage would be pretty simple, lets write it as a test code.

```perl
use Data::Dump qw(dd);

my $bst = BST->new();
$bst->insert(20);
$bst->insert(9);
$bst->insert(5);
$bst->insert(12);
$bst->insert(11);
$bst->insert(14);
$bst->insert(25);

dd $bst;
```

That works, it nicely dumps out whole structure, it is easily visible that the items are in correct order.

```perl
bless({
  root => bless({
    key   => 20,
    left  => bless({
               key   => 9,
               left  => bless({ key => 5 }, "Node"),
               right => bless({
                          key   => 12,
                          left  => bless({ key => 11 }, "Node"),
                          right => bless({ key => 14 }, "Node"),
                        }, "Node"),
             }, "Node"),
    right => bless({ key => 25 }, "Node"),
  }, "Node"),
}, "BST")
```

For finding the successor, we can build a method for BST class to iterate the tree in-order, basically a sorted sequence.

```perl
    method inorder_iterator() {
        my @queue = defined $self->root ? ($self->root) : ();
        return iterator {
            while(@queue != 0) {
                my $current = shift @queue;

                # skip empty
                next unless defined $current;

                # actual key
                return $current unless ref($current) eq 'Node';

                # expand the node
                unshift @queue, $current->left, $current->key, $current->right;
            }
            return;
        }
    }
```

Let's expand our test to check it is working:

```perl
use Test::More;
use Iterator::Simple qw(list);

my $bst = BST->new();
$bst->insert(20);
$bst->insert(9);
$bst->insert(5);
$bst->insert(12);
$bst->insert(11);
$bst->insert(14);
$bst->insert(25);

is_deeply list($bst->inorder_iterator()), [5,9,11,12,14,20,25];

done_testing;
```

The output is good:

```
ok 1
1..1
```

Now the final part would be to find a successor for a value. We will just iterate until the the numbers are smaller, then return next value.

```perl
    method inorder_successor($what_to_find) {
        my $it = $self->inorder_iterator();
        while(my $next = $it->next) {
            if($next >= $what_to_find) {
                return $it->();
            }
        }
        return;
    }
```

And we can test it works, by adding some checks before `done_testing` call.

```perl
is $bst->inorder_successor(9), 11;
is $bst->inorder_successor(14), 20;
```

The output is still good, the tests produces:

```
ok 1
ok 2
ok 3
1..3
```

The interface could be made better by adding type constraints and parameter protection.
