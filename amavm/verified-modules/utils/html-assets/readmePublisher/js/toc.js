// Function to create the unordered list with links
function createUnorderedList(items) {
    // Create the <ul> element
    const ul = document.createElement('ul');

    // Extract unique categories
    const uniqueCategories = [...new Set(items.map(item => item.category))];

    uniqueCategories.forEach(category => {
        const li = document.createElement('li');
        li.textContent = category;

        const subUl = document.createElement('ul');
        items
        .filter(item => item.category === category)
        .forEach(item => {
            const subLi = document.createElement('li');
            const a = document.createElement('a');
            a.textContent = item.text;
            a.href = item.url;
            subLi.appendChild(a);
            subUl.appendChild(subLi);
        });

        li.appendChild(subUl);
        ul.appendChild(li);
    });

    return ul;
}

// Find the container where the list will be added
const listContainer = document.getElementById('sidebar');

import items from '/menu/toc.json' with { type: 'json' }

// Create the list and append it to the container
const unorderedList = createUnorderedList(items);
listContainer.appendChild(unorderedList);
