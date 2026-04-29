import { useEffect, useState } from 'react';
import { apiFetch } from '@/src/lib/api';
import { Users as UsersIcon, Search, ShieldCheck } from 'lucide-react';

interface UserOut {
  id: number;
  name: string;
  email: string;
  level: number;
  is_active: boolean;
  created_at: string | null;
}

export default function Users() {
  const [users, setUsers] = useState<UserOut[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  useEffect(() => {
    apiFetch<UserOut[]>('/api/users/')
      .then(setUsers)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  const filtered = users.filter(
    (u) =>
      u.name.toLowerCase().includes(search.toLowerCase()) ||
      u.email.toLowerCase().includes(search.toLowerCase()),
  );

  return (
    <div className="p-8 max-w-5xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold text-stone-800">Registered Users</h2>
          <p className="text-sm text-stone-500 mt-0.5">{users.length} total accounts</p>
        </div>
      </div>

      {/* Search */}
      <div className="relative mb-6 max-w-sm">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-stone-400" />
        <input
          type="text"
          placeholder="Search by name or email…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full pl-9 pr-4 py-2.5 rounded-xl border border-stone-200 bg-white text-sm focus:outline-none focus:ring-2 focus:ring-emerald-400"
        />
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-48 text-stone-400">Loading…</div>
      ) : filtered.length === 0 ? (
        <div className="flex flex-col items-center justify-center h-48 text-stone-400">
          <UsersIcon className="w-12 h-12 mb-3 opacity-20" />
          <p>No users found</p>
        </div>
      ) : (
        <div className="bg-white rounded-2xl border border-stone-100 overflow-hidden shadow-sm">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-stone-100 text-stone-500 text-left">
                <th className="px-6 py-3 font-semibold">ID</th>
                <th className="px-6 py-3 font-semibold">Name</th>
                <th className="px-6 py-3 font-semibold">Email</th>
                <th className="px-6 py-3 font-semibold">Level</th>
                <th className="px-6 py-3 font-semibold">Status</th>
                <th className="px-6 py-3 font-semibold">Joined</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((u, i) => (
                <tr
                  key={u.id}
                  className={`border-b border-stone-50 hover:bg-stone-50 transition-colors ${
                    i === filtered.length - 1 ? 'border-b-0' : ''
                  }`}
                >
                  <td className="px-6 py-3 text-stone-400 font-mono">#{u.id}</td>
                  <td className="px-6 py-3 font-medium text-stone-800 flex items-center gap-2">
                    <div className="w-7 h-7 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center text-xs font-bold">
                      {u.name.charAt(0).toUpperCase()}
                    </div>
                    {u.name}
                  </td>
                  <td className="px-6 py-3 text-stone-500">{u.email}</td>
                  <td className="px-6 py-3">
                    <span className="flex items-center gap-1 text-amber-600 font-semibold">
                      <ShieldCheck className="w-3.5 h-3.5" />
                      Lvl {u.level}
                    </span>
                  </td>
                  <td className="px-6 py-3">
                    <span
                      className={`px-2 py-0.5 rounded-full text-xs font-semibold ${
                        u.is_active
                          ? 'bg-emerald-50 text-emerald-700'
                          : 'bg-red-50 text-red-600'
                      }`}
                    >
                      {u.is_active ? 'Active' : 'Inactive'}
                    </span>
                  </td>
                  <td className="px-6 py-3 text-stone-400">
                    {u.created_at
                      ? new Date(u.created_at).toLocaleDateString('en-GB', {
                          day: 'numeric',
                          month: 'short',
                          year: 'numeric',
                        })
                      : '—'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
